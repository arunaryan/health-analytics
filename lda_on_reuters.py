# -*- coding: utf-8 -*-
"""
Created on Thu Mar 17 10:08:43 2016

@author: aaryasomayajula

This script reads the reuters text documents dataset and computes topics using Latent Dirichlet Allocation (LDA) models.

"""

import numpy as np
import lda
import lda.datasets

X = lda.datasets.load_reuters()
vocab = lda.datasets.load_reuters_vocab()
titles = lda.datasets.load_reuters_titles()
X.shape

model = lda.LDA(n_topics=20, n_iter=500, random_state=1)
model.fit(X)
topic_word = model.topic_word_  # model.components_ also works
n_top_words = 8
for i, topic_dist in enumerate(topic_word):
    topic_words = np.array(vocab)[np.argsort(topic_dist)][:-n_top_words:-1]
    print('Topic {}: {}'.format(i, ' '.join(topic_words)))
