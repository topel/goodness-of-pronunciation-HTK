#!/usr/bin/env python

import sys
import os

global ceredir

class Cerevoz:
    def __init__( self, utterance ):
        """Output an utterance spoken by our beloved Heather voice"""        
        ceredir = '/Users/cavaco/Work/MILLA/software/cerevoice_sdk_3.1.0_darwin_i386_python25_9536_academic'        
        self.dryrun = False
        self.speak( utterance )
    
    def speak (self, utt):
        
        xmlFile = open ('utt.xml', 'w')
        xmlFile.write('<?xml version=\'1.0\'?>\n')
        xmlFile.write('<parent>\n')
        xmlFile.write(utt)
        xmlFile.write('\n</parent>\n')
        xmlFile.close()
        
        
        exe = ceredir + '/examples/basictts/basictts'
        voice = ceredir + '/voices/cerevoice_heather_3.0.8_22k.voice'
        lic = ceredir + '/voices/cerevoice_heather_3.0.8_22k.license'
        os.system(exe + ' ' + voice + ' ' + lic + ' ./utt.xml')

def usage( argv ):
    print 'Error: Too few arguments, no string for utterance was given!\n'
    print 'Usage: ' + argv[0] + ' <string>\n\n'
    print '   Please try again!'
    sys.exit(1)

        
def main( argv ):
    """Do something!"""
    
    if ( len(argv) < 2 ):
        usage( argv )

    utt = argv[1]
    # utt = 'I need  <prosody pitch="high">toilet paper</prosody>'
    print(utt)
    # Cerevoz ( utt )

    
if __name__ == '__main__':
    main ( sys.argv )
    