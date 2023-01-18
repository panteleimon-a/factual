#bash: python train.py --lang en --model word2vec --size 300 --output data/en_wiki_word2vec_300.txt
import argparse
import logging
import os
import jieba
import wiki as w
from gensim.models.fasttext import FastText
from gensim.models.word2vec import Word2Vec
from tqdm import tqdm
import multiprocessing
import pandas as pd

WIKIXML = '/Users/pante/factual/archive/w2v_model/data/enwiki-20230101-pages-articles-multistream1.xml-p1p41242.bz2'

from gensim.corpora.wikicorpus import WikiCorpus

class WikiSentences:
    def __init__(self, wiki_dump_path, lang):
        logging.info('Parsing wiki corpus')
        self.wiki = WikiCorpus(wiki_dump_path)
        self.lang = lang

    def __iter__(self):
        for sentence in self.wiki.get_texts():
            if self.lang == 'zh':
                yield list(jieba.cut(''.join(sentence), cut_all=False))
            else:
                yield list(sentence)

def get_args():
    parser = argparse.ArgumentParser(description='Train embedding')
    parser.add_argument('--lang', type=str, default='en', help='language')
    parser.add_argument('--model', type=str, default='word2vec', help='word embedding model')
    parser.add_argument('--output', type=str, required=True, help='output for word vectors')
    parser.add_argument('--size', type=int,default=300, help='embedding size')
    return parser.parse_args()


def main():
    args = get_args()

    # parse wiki dump
    wiki_sentences = WikiSentences(WIKIXML.format(lang=args.lang), args.lang)
    cores = multiprocessing.cpu_count()
    logging.info('Training model %s', args.model)
    if args.model == 'word2vec':
        model = Word2Vec(wiki_sentences, min_count=4,window=4,vector_size=300, alpha=0.03, min_alpha=0.0007, sg = 1,workers=cores-1)
    elif args.model == 'fasttext':
        args.output='en_wiki_word2vec_300.bin'
        model = FastText(wiki_sentences, min_count=4,window=4,vector_size=300, alpha=0.03, min_alpha=0.0007, sg = 1,workers=cores-1)
    else:
        logging.info('Unknown model %s, should be "word2vec" or "fasttext"', args.model)
        return
    logging.info('Training done.')

    logging.info('Save trained word vectors')
    if args.model == 'word2vec':
        model.wv.save(args.output)#save vectors for word2vec
    else:
        model.save(args.output)
    logging.info('Done')


if __name__ == "__main__":
    logging.basicConfig(format='[%(asctime)s] %(message)s', level=logging.INFO)
    os.makedirs('data/', exist_ok=True)
    main()