############TF-IDF vectors#####################
# needs a list of lists for words and docs along with a fasttext 'model'
text = []
for i in tokens:
  string = ' '.join(i)
  text.append(string)
tf_idf_vect = TfidfVectorizer(stop_words=None)
final_tf_idf = tf_idf_vect.fit_transform(text)
tfidf_feat = tf_idf_vect.get_feature_names_out()

#####################TFIDF model##########################################
tfidf_sent_vectors = []; # the tfidf-fasttext for each sentence/review is stored in this list
row=0;
errors=0
for sent in tokens: # for each review/sentence
    # print(sent)
    sentvec = np.zeros(20) # as word vectors are of zero length
    weightsum =0; # num of words with a valid vector in the sentence/review
    # if sent!=[]:
    for word in sent: # for each word in a review/sentence
        # print(word)
        # try:
        # if True: 
            vec = ft.get_word_vector(word)
            # for w2v: vec = model[word].wv

            # obtain the tf_idfidf of a word in a sentence/review
            tfidf = final_tf_idf [row, np.where(tfidf_feat==word)[0]] #tfidf_feat.index(word)]
            

            if tfidf.toarray()!=[]:
              tfnum = tfidf.toarray()[0][0]
              print(vec)
              sentvec += (vec * tfnum)
              weightsum += tfnum
        # except:
            # errors =+1
            # pass
    sent_vec /= weight_sum
    #print(np.isnan(np.sum(sent_vec)))
    # print(sent_vec)
    tfidf_sent_vectors.append(sent_vec)
    row += 1
# print(tfidf_sent_vectors)
# print('errors noted: '+str(errors))

# join the cosine distance vectors back to the dataframe:
query = np.array(list(query))
query = np.nan_to_num(query)
vectors = np.array(list(tfidf_sent_vectors))
vectors = np.nan_to_num(vectors)
cosine_similarities = pd.Series(cosine_similarity(query, vectors).flatten())
newsdf['FT_tfidf'] = cosine_similarities
