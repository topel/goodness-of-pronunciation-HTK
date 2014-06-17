#!/usr/bin/env python

# gop/gopThresholds.py ../../english_resources/milla2.txt ../../english_resources/milla2_align.phon

import sys
import os

global ceredir

class gopThresholds:
    '''
    Set the GOP thresholds for each target English phone
    Uses the builtin TTS from Mac Mavericks
    '''
    def __init__( self, fileName, fileName2 ):
        """reads sentences in fileName, and artificial bad prons in fileName2"""
        self.runGOP( fileName, fileName2 )
        
    def runGOP ( self, fileName, fileName2 ):
        """fileName: sentences; fileName2: artificial bad prons; """
        file1 = open (fileName, 'r')
        sentences = file1.readlines()
        file1.close()
        file2 = open (fileName2, 'r')
        pronsAlign = file2.readlines()
        file2.close()
        
        ind = 1
        for sent in sentences:
            wavfile = 'alex_' + str(ind) + '.aiff'
            os.system('say -v Alex ' +  sent)
#            os.system('say -v Alex --file-format=WAVE --data-format=LEF32@16000 --bit-rate=256000 -o ' + outfile  + ' ' + sent )
            #os.system('say -v Alex --file-format=WAVE --data-format=LEF32@16000 -o ' + wavfile  + ' ' + sent )
            os.system('say -v Alex -o ' + wavfile  + ' ' + sent )
            tmp1 = open ('tmp.txt', 'w')
            pron = pronsAlign[ind]
            tmp1.write(sent)
            tmp1.write(pron)
            tmp1.write(pron)
            tmp1.close()

            os.system( './gop_EN_forPython_WAVEINPUT.sh ' + wavfile + ' tmp.txt' )
            
            break
        
def usage( argv ):
    print 'Error: Too few arguments, no input files specified, exiting now!\n'
    print 'Usage: ' + argv[0] + ' <sentence text file> <pron file>\n\n'
    print '   Please try again!'
    sys.exit(1)
         
def main( argv ):
    """Do something!"""
    
    if ( len(argv) < 3 ):
        usage( argv )

    SentenceFile = argv[1]
    PronFile = argv[2]
    
    gopThresholds( SentenceFile, PronFile )


    
if __name__ == '__main__':
    main ( sys.argv )
           
        
  
    
    