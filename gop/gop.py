#!/usr/bin/env python

# cd /Users/cavaco/Work/MILLA/software/gop_IRIT
# gop/gop.py ../../english_resources/milla2.txt ../../english_resources/milla2_align.phon ../../english_resources/milla2.phon

import sys
import os
import cerevoz as tts

class Gop:
    def __init__( self, fileName, fileName2, fileName3 ):
        """read all prompts and corresponding prons from two TXT files
        and produce some actions"""
        self.tryGOP( fileName, fileName2, fileName3 )
    
    def tryGOP ( self, fileName, fileName2, fileName3 ):
        """fileName: sentences; fileName2: corresponding prons; fileName3: prons with alternates; """
        file1 = open (fileName, 'r')
        sentences = file1.readlines()
        file1.close()
        file2 = open (fileName2, 'r')
        pronsAlign = file2.readlines()
        file2.close()
        file3 = open (fileName3, 'r')
        pronsASR = file3.readlines()
        file3.close()
        ind = 0;
                
        for sent in sentences:
            tmp1 = open ('tmp.txt', 'w')
            pron = pronsAlign[ind]
            pron2 = pronsASR[ind]
            tmp1.write(sent)
            tmp1.write(pron)
            tmp1.write(pron2)
            tmp1.close()
            
            sent = sent.rstrip('\n')
            pron = pron.rstrip('\n')
            pron2 = pron2.rstrip('\n')
            print sent, pron, pron2
            
            sent = 'Please say <break time="1s"/> ' + sent
            voz = tts.Cerevoz(sent)
            
            os.system( './gop_EN_forPython.sh tmp.txt' )

            utt = 'Hit a key to go to the next pronunciation exercise.'
            voz = tts.Cerevoz(utt)
            raw_input(utt)
            
            ind+=1
            # break
        
def usage( argv ):
    print 'Error: Too few arguments, no input files specified, exiting now!\n'
    print 'Usage: ' + argv[0] + ' <sentence text file> <pron file> <pron file with alternates>\n\n'
    print '   Please try again!'
    sys.exit(1)

def main( argv ):
    """Do something!"""

    if ( len(argv) < 4 ):
        usage( argv )

    SentenceFile = argv[1]
    PronFile = argv[2]
    ASRPronFile = argv[3]

    Gop( SentenceFile, PronFile, ASRPronFile )

if __name__ == "__main__":
    main( sys.argv )
