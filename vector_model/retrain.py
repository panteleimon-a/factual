#bash: python train.py --lang en --model word2vec --size 300 --output data/en_wiki_word2vec_300.txt
import argparse
import logging
import os
import jieba
import wiki as w
from gensim.models import KeyedVectors
from gensim.corpora.wikicorpus import WikiCorpus, tokenize
from gensim.models.fasttext import FastText
from gensim.models.word2vec import Word2Vec, LineSentence
from gensim.models.doc2vec import Doc2Vec, TaggedDocument
from tqdm import tqdm
import multiprocessing
import pandas as pd
from bs4 import BeautifulSoup
from gensim.test.utils import datapath, simple_preprocess
import smart_open
from datetime import datetime
now = datetime.now()

WIKIXML = "/Users/pante/Git_Repositories/factual/enwiki-20230101-pages-articles-multistream1.xml-p1p41242.bz2"

def read_corpus(fname, tokens_only=False):
    with smart_open.open(fname, encoding="iso-8859-1") as f:
        for i, line in enumerate(f):
            tokens = simple_preprocess(line)
            if tokens_only:
                yield tokens
            else:
                # For training data, add tags
                yield TaggedDocument(tokens, [i])

class WikiSentences:
    def __init__(self, wiki_dump_path, lang):
        logging.info('Parsing wiki corpus')
        self.wiki = WikiCorpus(wiki_dump_path)
        self.lang = lang

    def __iter__(self):
        for doc in self.wiki.get_texts():
            if self.lang == 'zh':
                yield list(jieba.cut(''.join(doc), cut_all=False))
            else:
                yield list(doc)

def get_args():
    parser = argparse.ArgumentParser(description='Train embedding')
    parser.add_argument('--lang', type=str, default='en', help='language')
    parser.add_argument('--model', type=str, default='word2vec', help='word embedding model')
    parser.add_argument('--output', type=str, required=True, help='output for word vectors')
    parser.add_argument('--size', type=int,default=300, help='embedding size')
    parser.add_argument('--dataset', type=int,default=300, help='wikicorpus vocab to build')
    return parser.parse_args()


def main():
    args = get_args()
    #count system cores to define workers
    cores = multiprocessing.cpu_count()
    logging.info('Training model %s', args.model)
    if args.model == 'word2vec':
        args.output=args.output.__add__(now)
        model=KeyedVectors.load("/Users/pante/Git_Repositories/factual/skipgram/en_wiki_word2vec_300.txt")
        wiki_sentences = WikiSentences(WIKIXML.format(lang=args.lang), args.lang)
        model=model.build_vocab(wiki_sentences,update=True)
        model.train(wiki_sentences, total_examples=model.corpus_count) 
    elif args.model == 'fasttext':
        model=KeyedVectors.load("/Users/pante/Git_Repositories/factual/skipgram/en_wiki_fasttext_300.bin")
        wiki_sentences = WikiSentences(WIKIXML.format(lang=args.lang), args.lang)
        args.output='cbow/en_wiki_fasttext_300.bin'.__add__(now)
        model = FastText(wiki_sentences, min_count=4,window=4,vector_size=300, alpha=0.03, min_alpha=0.0007, sg = 0,workers=cores-1)
    elif args.model == 'doc2vec':
        #read object containing corpuses as TaggedDocuments elements
        #train_corpus=[tagged_doc for tagged_doc in read_corpus(WIKIXML)]
        wiki_sentences=read_corpus(WIKIXML)
        train_corpus=[tagged_doc for tagged_doc in wiki_sentences]
        args.output='cbow/en_wiki_doc2vec_300.bin'.__add__(now)
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
    os.makedirs('data/', exist_ok=True)
    main()