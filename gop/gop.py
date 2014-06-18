#!/usr/bin/env python

# cd /Users/cavaco/Work/MILLA/software/gop_IRIT
# gop/gop.py ../../english_resources/milla2.txt ../../english_resources/milla2_align.phon ../../english_resources/milla2.phon 7 ../../english_resources/spanish_thresholds.txt 

import sys
import os
import cerevoz as tts

class Gop:
    def __init__( self, threshFile ):
        """read all prompts and corresponding prons from two TXT files
        and produce some actions"""
        self.thresholds = {}
        self.defaultThresh = 2.0
        self.loadThresholds (threshFile)
        # self.tryGOP( fileName, fileName2, fileName3, ind )
    
    def loadThresholds (self, threshFile):
        """Reads a file containing the GOP score thresholds for each phone"""
        file1 = open (threshFile, 'r')
        lignes = file1.readlines()
        file1.close()
        for sent in lignes:
            sent = sent.rstrip('\n')
            if (len(sent) > 1):
                phone=sent.split(' ')[0]
                thresh=sent.split(' ')[1]
                # print str(len(sent)) + phone + ' ' + thresh
                self.thresholds[phone] = float(thresh)                    
        
        
    def tryGOP ( self, fileName, fileName2, fileName3, ind ):
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
        
        sent = sentences[ind]
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
        
        if(ind==7):
            tts.Cerevoz('This sentence tests v like very and b like bad')

        if(ind==10):
            tts.Cerevoz('This sentence tests s like salt and z like zebra')
            
        sent2 = 'Please say <break time="1s"/> ' + sent
        tts.Cerevoz(sent2)
        print sent
            
        os.system( './gop_EN_forPython.sh tmp.txt' )
            
        repeat = self.evaluatePron()
        # print repeat
         
        nbIt = 1
        maxRepeat = 2
        while(repeat):
            utt = 'You could improve this! <break time="1s"/> Listen to me <break time="1s"/> ' + sent
            tts.Cerevoz(utt)
            tts.Cerevoz('Try again. Your turn')
            os.system('./gop_EN_forPython.sh tmp.txt')
            repeat = self.evaluatePron()
            nbIt+=1
            # print str(repeat) + ' ' + str(nb_it)
            if (nbIt > maxRepeat):
                tts.Cerevoz('OK! ')
                break
            
        tts.Cerevoz('Perfect! Let\'s try another sentence')
        os.system('rm -r tmp.*')    
#         utt = 'Hit a key to go to the next pronunciation exercise.'
#         tts.Cerevoz(utt)
#         raw_input(utt)
        
        
    def evaluatePron( self ):
        """Reads GOP scores and returns a boolean to ask the user to try again or not"""
        print('EVALUATE')
        gopfile = open ('gop.txt', 'r')
        lignes = gopfile.readlines()
        gopfile.close()
        for sent in lignes:
            sent = sent.rstrip('\n')
            score = sent.split(' ')[0]
            score = float(score)
            phone = sent.split(' ')[3]
            if phone in self.thresholds:
                th = self.thresholds[phone]
            else:
                th = self.defaultThresh
            # print phone + ' th=' + str(th) + ' sc=' + str(score)
            if(score > th):
                return True
        return False
        
def usage( argv ):
    print 'Error: Too few arguments, no input files specified, exiting now!\n'
    print 'Usage: ' + argv[0] + \
    ' <sentence text file> ' + \
    '<pron file> ' + \
    '<pron file with alternates> ' + \
    '<index> ' + \
    '<Threshold file>\n\n'
    
    print '   Please try again!'
    sys.exit(1)

def main( argv ):
    """Do something!"""

    if ( len(argv) < 6 ):
        usage( argv )

    sentenceFile = argv[1]
    pronFile = argv[2]
    ASRPronFile = argv[3]
    ind = int(argv[4])
    threshFile = argv[5]

    gop_ = Gop( threshFile )
    gop_.tryGOP( sentenceFile, pronFile, ASRPronFile, ind )

    ind = 10
    gop_.tryGOP( sentenceFile, pronFile, ASRPronFile, ind )
    
if __name__ == "__main__":
    main( sys.argv )
