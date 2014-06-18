#!/usr/bin/env python

# gop/gopThresholds.py ../../english_resources/milla2.txt ../../english_resources/milla2_align_wrongProns.phon ../../english_resources/milla2.phon

import sys
import os

global ceredir

class gopThresholds:
    '''
    Set the GOP thresholds for each target English phone
    Uses the builtin TTS from Mac Mavericks
    '''
    def __init__( self, fileName, fileName2, fileName3 ):
        """reads sentences in fileName, and artificial bad prons in fileName2"""
        self.runGOP( fileName, fileName2, fileName3 )
        
    def runGOP ( self, fileName, fileName2, fileName3 ):
        """fileName: sentences; fileName2: artificial bad prons; """
        file1 = open (fileName, 'r')
        sentences = file1.readlines()
        file1.close()
        file2 = open (fileName2, 'r')
        pronsAlign = file2.readlines()
        file2.close()
        file3 = open (fileName3, 'r')
        pronsASR = file3.readlines()
        file3.close()

        speaker = 'Alex'
        # speaker = 'Vicki'
        
        ind = 0
        for sent in sentences:
            if (ind < 10):
                ind+=1
                continue
            print ind
            
            aiff = 'alex_' + str(ind) + '.aiff'
            os.system('say -v ' + speaker + ' '+  sent )
            os.system('say -v ' + speaker + '  -o ' + aiff  + ' ' + sent)
            tmp1 = open ('tmp.txt', 'w')
            pron = pronsAlign[ind]
            pron2 = pronsASR[ind]
            tmp1.write(sent)
            tmp1.write(pron)
            tmp1.write(pron2)
            tmp1.close()

            os.system( './gop_EN_forPython.sh ' + aiff + ' tmp.txt' )
            ind += 1
            break
        
def usage( argv ):
    print 'Error: Too few arguments, no input files specified, exiting now!\n'
    print 'Usage: ' + argv[0] + ' <sentence text file> <pron file>\n\n'
    print '   Please try again!'
    sys.exit(1)
         
def main( argv ):
    """Do something!"""
    
    if ( len(argv) < 4 ):
        usage( argv )

    SentenceFile = argv[1]
    PronFile = argv[2]
    ASRPronFile = argv[3]
    
    gopThresholds( SentenceFile, PronFile, ASRPronFile )


    
if __name__ == '__main__':
    main ( sys.argv )
           
        
  
    
    