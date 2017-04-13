#!/usr/bin/env python

# ==================================
# Author: Italo Balestra
# it_b@hotmail.com
# 13/04/2017
# ==================================

"""
Module for matching indexes of elements in two lists, A and B.
This works if A is smaller than B and B has no duplicates.
"""

def matchIDs(A, B):
    """
    Input
     A = name of first list
     B = name of second list
    Output
     List of indexes of matching elements in B   
     Index = -1 if no match is found any in B.  
    """
    
    dicB = dict((val, i) for i, val in enumerate(B))
    return [dicB[x] if x in B else -1 for x in A]

if __name__ == '__main__':
    matchIDs()
