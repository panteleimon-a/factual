# bash: 
'''
source ~/venv-metal/bin/activate
python train.py --lang en --model word2vec --size 300 --output data/en_wiki_word2vec_300.txt
!pip install transformers
'''
import argparse
import tensorflow as tf
import logging
import os
import jieba
import wiki as w
from tqdm import tqdm
import multiprocessing
import shutil
import pandas as pd
from bs4 import BeautifulSoup
from gensim.test.utils import datapath, simple_preprocess
import smart_open
from transformers import BertTokenizer, TFBertForSequenceClassification
from transformers import InputExample, InputFeatures

# training data
URL = "https://ai.stanford.edu/~amaas/data/sentiment/aclImdb_v1.tar.gz"
fname="aclImdb_v1.tar.gz"

class preproc:
    def __init__(self, fname):
        logging.info('Loading training dataset')
        self.dataset = tf.keras.utils.get_file(fname=fname,origin=URL,untar=True,cache_dir='.',cache_subdir='')
        # Create main directory path ("/aclImdb")
        self.main_dir = os.path.join(os.path.dirname(self.dataset), 'aclImdb')
        # main_dir = os.path.join(path,"trainingtweet.csv")
        # Create sub directory path ("/aclImdb/train")
        self.train_dir = os.path.join(self.main_dir, 'train')
        # Remove unsup folder since this is a supervised learning task
        self.remove_dir = os.path.join(self.train_dir, 'unsup')
        shutil.rmtree(self.remove_dir)
        # View the final train folder
        print(os.listdir(self.train_dir))
        return self
    
    def preproc(self):
        self.train = tf.keras.preprocessing.text_dataset_from_directory('./aclImdb/train', batch_size=30000, validation_split=0.2, 
                                                                   subset='training', seed=123)
        self.test = tf.keras.preprocessing.text_dataset_from_directory(
            './aclImdb/train', batch_size=30000, validation_split=0.2, subset='validation', seed=123
            )
        for i in self.train.take(1):
            self.train_feat = i[0].numpy()
            self.train_lab = i[1].numpy()

        self.train = pd.DataFrame([self.train_feat, self.train_lab]).T
        self.train.columns = ['DATA_COLUMN', 'LABEL_COLUMN']
        self.train['DATA_COLUMN'] = train['DATA_COLUMN'].str.decode("utf-8")
        self.train.head()

        for j in self.test.take(1):
            self.test_feat = j[0].numpy()
            self.test_lab = j[1].numpy()
        
        self.test = pd.DataFrame([test_feat, test_lab]).T
        self.test.columns = ['DATA_COLUMN', 'LABEL_COLUMN']
        self.test['DATA_COLUMN'] = test['DATA_COLUMN'].str.decode("utf-8")
        self.test.head()

        return self

    def convert_data_to_examples(self, DATA_COLUMN='DATA_COLUMN', LABEL_COLUMN='LABEL_COLUMN'): 
        self.train_InputExamples = self.train.apply(lambda x: InputExample(guid=None,text_a = x[DATA_COLUMN],text_b = None,label = x[LABEL_COLUMN]),axis = 1)
        self.validation_InputExamples = self.test.apply(lambda x: InputExample(guid=None,text_a = x[DATA_COLUMN],text_b = None,label = x[LABEL_COLUMN]),axis = 1)
        return self.train_InputExamples, self.validation_InputExamples

        train_InputExamples, validation_InputExamples = convert_data_to_examples(train,test,'DATA_COLUMN','LABEL_COLUMN')

        return self
    
    def convert_examples_to_tf_dataset(self, examples=list(self.train_InputExamples), tokenizer, max_length=128):
        self.features = [] # -> will hold InputFeatures to be converted later
        for e in examples:
            # Documentation is really strong for this method, so please take a look at it
            self.input_dict = tokenizer.encode_plus(
                e.text_a,
                add_special_tokens=True,
                max_length=max_length, # truncates if len(s) > max_length
                return_token_type_ids=True,
                return_attention_mask=True,
                pad_to_max_length=True, # pads to the right by default # CHECK THIS for pad_to_max_length
                truncation=True
            )
            input_ids, token_type_ids, attention_mask = (self.input_dict["input_ids"],
                self.input_dict["token_type_ids"], self.input_dict['attention_mask'])
            self.features.append(
                InputFeatures(
                    input_ids=input_ids, attention_mask=attention_mask, token_type_ids=token_type_ids, label=e.label
                )
            )
        def gen():
            for f in self.features:
                yield (
                    {
                        "input_ids": f.input_ids,
                        "attention_mask": f.attention_mask,
                        "token_type_ids": f.token_type_ids,
                    },
                    f.label,
                )
        return tf.data.Dataset.from_generator(
            gen,
            ({"input_ids": tf.int32, "attention_mask": tf.int32, "token_type_ids": tf.int32}, tf.int64),
            (
            {"input_ids": tf.TensorShape([None]),"attention_mask": tf.TensorShape([None]), 
            "token_type_ids": tf.TensorShape([None]),
            },
            tf.TensorShape([]),), self,
            )

def train(args):
    #newBert_newMe
    model = TFBertForSequenceClassification.from_pretrained("bert-base-uncased")
    if args.fp16:
        model.half()
    model.cuda()
    tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")
    model.summary()

    train_InputExamples, validation_InputExamples = preproc().convert_data_to_examples(train, test, DATA_COLUMN, LABEL_COLUMN)
    train_data = preproc().convert_examples_to_tf_dataset(list(train_InputExamples), tokenizer)
    train_data = train_data.shuffle(100).batch(args.batch_size).repeat(2)

    validation_data = preproc().convert_examples_to_tf_dataset(list(validation_InputExamples), tokenizer)
    validation_data = validation_data.batch(args.batch_size)
    
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=3e-5, epsilon=1e-08, clipnorm=1.0),loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),metrics=[tf.keras.metrics.SparseCategoricalAccuracy('accuracy')])
    #This should take time. You can run it in VS and stop it after 20 hours. This way it won't run forever. Stopping it manually will not interfere with the model
    #proceed after doing your due diligence; this will eat up your ram!
    model.fit(train_data, epochs=2, validation_data=validation_data)

def get_args():
    parser = argparse.ArgumentParser(description='Train embedding')
    parser.add_argument('--batch_size', type=int, default='32', help='training batch size')
    parser.add_argument('--fp16', type=str, default='n', help='is the model subsidized? (float16 embeddings)')
    parser.add_argument('--output', type=str, required=True, help='output for word vectors')
    parser.add_argument('--size', type=int,default=300, help='embedding size')
    return parser.parse_args()



def main():
    args = get_args()
    #count system cores to define workers
    cores = multiprocessing.cpu_count()
    logging.info('Training model %s', args.model)
    if args.model == 'word2vec':
        wiki_sentences = WikiSentences(WIKIXML.format(lang=args.lang), args.lang)
        model = Word2Vec(wiki_sentences, min_count=4,window=4,vector_size=300, alpha=0.03, min_alpha=0.0007, sg = 0,workers=cores-1)
    elif args.model == 'fasttext':
        wiki_sentences = WikiSentences(WIKIXML.format(lang=args.lang), args.lang)
        args.output='cbow/en_wiki_fasttext_300.bin'
        model = FastText(wiki_sentences, min_count=4,window=4,vector_size=300, alpha=0.03, min_alpha=0.0007, sg = 0,workers=cores-1)
    elif args.model == 'doc2vec':
        #read object containing corpuses as TaggedDocuments elements
        #train_corpus=[tagged_doc for tagged_doc in read_corpus(WIKIXML)]
        wiki_sentences=read_corpus(WIKIXML)
        train_corpus=[tagged_doc for tagged_doc in wiki_sentences]
        args.output='cbow/en_wiki_doc2vec_300.bin'
        max_epochs = 3
        vec_size = 300
        alpha = 0.03
        #dm=1 refers to PV-DM, while dm=0 refers to PV-DBOW
        #dbow_words=1 skipgram
        model = Doc2Vec(dbow_words=1,dm_mean=0,window=4,vector_size=vec_size, alpha=alpha, min_alpha=0.0007, dm=1, workers=cores-1, epochs=max_epochs)
        model.build_vocab(train_corpus)
        model.train(train_corpus, total_examples=model.corpus_count, epochs=model.epochs)
    else:
        logging.info('Unknown model %s, should be "word2vec" or "fasttext" or "doc2vec"', args.model)
        return
    logging.info('Training done.')

    logging.info('Save trained word vectors')
    
    if args.model == 'word2vec':
        model.wv.save(args.output)#save vectors for word2vec/doc2vec
    else:
        model.save(args.output)
    logging.info('Done')


if __name__ == "__main__":
    logging.basicConfig(format='[%(asctime)s] %(message)s', level=logging.INFO)
    os.makedirs('models/', exist_ok=True)
    main()