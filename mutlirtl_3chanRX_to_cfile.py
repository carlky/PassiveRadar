#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: mutlirtl_3chanRX_to_cfile
# Author: Carl Kylin
# Description: 3 chanels saved to 3 separate cfiles
# Generated: Tue Mar 20 12:41:39 2018
##################################################

from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import gr
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from optparse import OptionParser
import multi_rtl


class mutlirtl_3chanRX_to_cfile(gr.top_block):

    def __init__(self, ch0_fname="ch0.cfile", ch0_id_string="0", ch1_fname="ch1.cfile", ch1_id_string="1", ch2_fname="ch2.cfile", ch2_id_string="2", f_rec=600e6, f_sync=600e6, nsamples=4000000, samp_rate=1e6):
        gr.top_block.__init__(self, "mutlirtl_3chanRX_to_cfile")

        ##################################################
        # Parameters
        ##################################################
        self.ch0_fname = ch0_fname
        self.ch0_id_string = ch0_id_string
        self.ch1_fname = ch1_fname
        self.ch1_id_string = ch1_id_string
        self.ch2_fname = ch2_fname
        self.ch2_id_string = ch2_id_string
        self.f_rec = f_rec
        self.f_sync = f_sync
        self.nsamples = nsamples
        self.samp_rate = samp_rate

        ##################################################
        # Blocks
        ##################################################
        self.multi_rtl_source_1 = multi_rtl.multi_rtl_source(sample_rate=samp_rate, num_channels=3, ppm=0, sync_center_freq=f_sync, rtlsdr_id_strings= [ 
          ch0_id_string, 
          ch1_id_string, 
          ch2_id_string, 
          "3", 
          "4", 
          "5", 
          "6", 
          "7", 
          "8", 
          "9", 
          "10", 
          "11", 
          "12", 
          "13", 
          "14", 
          "15", 
          "16", 
          "17", 
          "18", 
          "19", 
          "20", 
          "21", 
          "22", 
          "23", 
          "24", 
          "25", 
          "26", 
          "27", 
          "28", 
          "29", 
          "30", 
          "31", 
          ])
        self.multi_rtl_source_1.set_sync_gain(10, 0)
        self.multi_rtl_source_1.set_gain(10, 0)
        self.multi_rtl_source_1.set_center_freq(f_rec, 0)
        self.multi_rtl_source_1.set_gain_mode(False, 0)
        self.multi_rtl_source_1.set_sync_gain(10, 1)
        self.multi_rtl_source_1.set_gain(10, 1)
        self.multi_rtl_source_1.set_center_freq(f_rec, 1)
        self.multi_rtl_source_1.set_gain_mode(False, 1)
        self.multi_rtl_source_1.set_sync_gain(10, 2)
        self.multi_rtl_source_1.set_gain(10, 2)
        self.multi_rtl_source_1.set_center_freq(f_rec, 2)
        self.multi_rtl_source_1.set_gain_mode(False, 2)
          
        self.blocks_head_2 = blocks.head(gr.sizeof_gr_complex*1, nsamples)
        self.blocks_head_1 = blocks.head(gr.sizeof_gr_complex*1, nsamples)
        self.blocks_head_0 = blocks.head(gr.sizeof_gr_complex*1, nsamples)
        self.blocks_file_sink_2 = blocks.file_sink(gr.sizeof_gr_complex*1, ch2_fname, False)
        self.blocks_file_sink_2.set_unbuffered(False)
        self.blocks_file_sink_1 = blocks.file_sink(gr.sizeof_gr_complex*1, ch1_fname, False)
        self.blocks_file_sink_1.set_unbuffered(False)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_gr_complex*1, ch0_fname, False)
        self.blocks_file_sink_0.set_unbuffered(False)

        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_head_0, 0), (self.blocks_file_sink_0, 0))    
        self.connect((self.blocks_head_1, 0), (self.blocks_file_sink_1, 0))    
        self.connect((self.blocks_head_2, 0), (self.blocks_file_sink_2, 0))    
        self.connect((self.multi_rtl_source_1, 0), (self.blocks_head_0, 0))    
        self.connect((self.multi_rtl_source_1, 1), (self.blocks_head_1, 0))    
        self.connect((self.multi_rtl_source_1, 2), (self.blocks_head_2, 0))    

    def get_ch0_fname(self):
        return self.ch0_fname

    def set_ch0_fname(self, ch0_fname):
        self.ch0_fname = ch0_fname
        self.blocks_file_sink_0.open(self.ch0_fname)

    def get_ch0_id_string(self):
        return self.ch0_id_string

    def set_ch0_id_string(self, ch0_id_string):
        self.ch0_id_string = ch0_id_string

    def get_ch1_fname(self):
        return self.ch1_fname

    def set_ch1_fname(self, ch1_fname):
        self.ch1_fname = ch1_fname
        self.blocks_file_sink_1.open(self.ch1_fname)

    def get_ch1_id_string(self):
        return self.ch1_id_string

    def set_ch1_id_string(self, ch1_id_string):
        self.ch1_id_string = ch1_id_string

    def get_ch2_fname(self):
        return self.ch2_fname

    def set_ch2_fname(self, ch2_fname):
        self.ch2_fname = ch2_fname
        self.blocks_file_sink_2.open(self.ch2_fname)

    def get_ch2_id_string(self):
        return self.ch2_id_string

    def set_ch2_id_string(self, ch2_id_string):
        self.ch2_id_string = ch2_id_string

    def get_f_rec(self):
        return self.f_rec

    def set_f_rec(self, f_rec):
        self.f_rec = f_rec
        self.multi_rtl_source_1.set_center_freq(self.f_rec, 0)
        self.multi_rtl_source_1.set_center_freq(self.f_rec, 1)
        self.multi_rtl_source_1.set_center_freq(self.f_rec, 2)

    def get_f_sync(self):
        return self.f_sync

    def set_f_sync(self, f_sync):
        self.f_sync = f_sync
        self.multi_rtl_source_1.set_sync_center_freq(self.f_sync)

    def get_nsamples(self):
        return self.nsamples

    def set_nsamples(self, nsamples):
        self.nsamples = nsamples
        self.blocks_head_0.set_length(self.nsamples)
        self.blocks_head_1.set_length(self.nsamples)
        self.blocks_head_2.set_length(self.nsamples)

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate


def argument_parser():
    parser = OptionParser(option_class=eng_option, usage="%prog: [options]")
    parser.add_option(
        "", "--ch0-fname", dest="ch0_fname", type="string", default="ch0.cfile",
        help="Set ch0-fname [default=%default]")
    parser.add_option(
        "", "--ch0-id-string", dest="ch0_id_string", type="string", default="0",
        help="Set ch0-id-string [default=%default]")
    parser.add_option(
        "", "--ch1-fname", dest="ch1_fname", type="string", default="ch1.cfile",
        help="Set ch1-fname [default=%default]")
    parser.add_option(
        "", "--ch1-id-string", dest="ch1_id_string", type="string", default="1",
        help="Set ch1-id-string [default=%default]")
    parser.add_option(
        "", "--ch2-fname", dest="ch2_fname", type="string", default="ch2.cfile",
        help="Set ch2-fname [default=%default]")
    parser.add_option(
        "", "--ch2-id-string", dest="ch2_id_string", type="string", default="2",
        help="Set ch2-id-string [default=%default]")
    parser.add_option(
        "", "--f-rec", dest="f_rec", type="eng_float", default=eng_notation.num_to_str(600e6),
        help="Set f-rec [default=%default]")
    parser.add_option(
        "", "--f-sync", dest="f_sync", type="eng_float", default=eng_notation.num_to_str(600e6),
        help="Set f-sync [default=%default]")
    parser.add_option(
        "", "--nsamples", dest="nsamples", type="intx", default=4000000,
        help="Set nsamples [default=%default]")
    parser.add_option(
        "", "--samp-rate", dest="samp_rate", type="eng_float", default=eng_notation.num_to_str(1e6),
        help="Set samp-rate [default=%default]")
    return parser


def main(top_block_cls=mutlirtl_3chanRX_to_cfile, options=None):
    if options is None:
        options, _ = argument_parser().parse_args()

    tb = top_block_cls(ch0_fname=options.ch0_fname, ch0_id_string=options.ch0_id_string, ch1_fname=options.ch1_fname, ch1_id_string=options.ch1_id_string, ch2_fname=options.ch2_fname, ch2_id_string=options.ch2_id_string, f_rec=options.f_rec, f_sync=options.f_sync, nsamples=options.nsamples, samp_rate=options.samp_rate)
    tb.start()
    tb.wait()


if __name__ == '__main__':
    main()
