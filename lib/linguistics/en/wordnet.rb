#!/usr/bin/ruby
# 
# This file contains functions for finding relations for English words. It
# requires the Ruby-WordNet module to be installed; if it is not installed,
# calling the functions defined by this file will raise NotImplemented
# exceptions if called. Requiring this file adds functions and constants to the
# Linguistics::EN module.
# 
# == Authors
# 
# * Michael Granger <ged@FaerieMUD.org>
# 
# == Copyright
#
# Copyright (c) 2003 The FaerieMUD Consortium. All rights reserved.
# 
# This module is free software. You may use, modify, and/or redistribute this
# software under the terms of the Perl Artistic License. (See
# http://language.perl.com/misc/Artistic.html)
# 
# == Version
#
#  $Id: wordnet.rb,v 1.1 2003/09/11 04:58:17 deveiant Exp $
# 

module Linguistics
module EN

	@hasWordnet		= false
	@wnError		= nil
	@wnLexicon		= nil

	# Load WordNet and open the lexicon if possible, saving the error that
	# occurs if anything goes wrong.
	begin
		require 'wordnet'
		@hasWordnet = true
	rescue LoadError => err
		@wnError = err
	end


	#################################################################
	###	M O D U L E   M E T H O D S
	#################################################################
	class << self

		### Returns +true+ if WordNet was loaded okay
		def hasWordnet? ; @hasWordnet; end

		### If #haveWordnet? returns +false+, this can be called to fetch the
		### exception which was raised when WordNet was loaded.
		def wnError ; @wnError; end

		### The instance of the WordNet::Lexicon used for all Linguistics WordNet
		### functions.
		def wnLexicon
			if @wnError
				raise NotImplementedError,
					"WordNet functions are not loaded: %s" %
					@wnError.message
			end

			@wnLexicon ||= WordNet::Lexicon::new
		end

		### Make a function that calls the method +meth+ on the synset of an input
		### word.
		def def_synset_function( meth )
			(class << self; self; end).instance_eval do
				define_method( meth ) {|*args|
					word, pos, sense = *args
					raise ArgumentError,
						"wrong number of arguments (0 for 1)" unless word
					sense ||= 1

					begin
						syn = synset( word.to_s, pos, sense )
						return syn.nil? ? nil : syn.send( meth )
					rescue WordNet::LookupError
						return nil
					end
				}
			end
		end
	end



	#################################################################
	###	W O R D N E T   I N T E R F A C E
	#################################################################

	###############
	module_function
	###############

	### Look up the synset associated with the given word or collocation in the
	### WordNet lexicon and return a WordNet::Synset object.
	def synset( word, pos=nil, sense=1 )
		lex = Linguistics::EN::wnLexicon
		if pos.is_a?( Fixnum)
			sense = pos
			pos = nil
		end
		postries = pos ? [pos] : [:noun, :verb, :adjective, :adverb, :other]
		syn = nil

		postries.each {|pos|
			break if syn = lex.lookupSynsets( word.to_s, pos, sense )
		}

		return syn
	end


	### Look up all the synsets associated with the given word or collocation in
	### the WordNet lexicon and return an Array of WordNet::Synset objects. If
	### +pos+ is +nil+, return synsets for all parts of speech.
	def synsets( word, pos=nil )
		lex = Linguistics::EN::wnLexicon
		postries = pos ? [pos] : [:noun, :verb, :adjective, :adverb, :other]
		syns = []

		postries.each {|pos|
			syns << lex.lookupSynsets( word.to_s, pos )
		}

		return syns.flatten.compact
	end


	# Returns definitions and/or example sentences as a String.
	def_synset_function :gloss

	# Returns definitions and/or example sentences as an Array.
	def_synset_function :glosses

	# Return nouns or verbs that have the same hypernym as the receiver.
	def_synset_function :coordinates

	# Returns the Array of synonyms contained in the synset for the receiver.
	def_synset_function :words
	def_synset_function :synonyms

	# Returns the name of the lexicographer file that contains the raw data for
	# the receiver.
	def_synset_function :lexInfo

	def_synset_function :frames

	def_synset_function :antonyms
	def_synset_function :hypernyms
	def_synset_function :entailment
	def_synset_function :hyponyms
	def_synset_function :causes
	def_synset_function :verbgroups
	def_synset_function :similarTo
	def_synset_function :participles
	def_synset_function :pertainyms
	def_synset_function :attributes
	def_synset_function :derivedFrom
	def_synset_function :seeAlso
	def_synset_function :functions

	def_synset_function :meronyms
	def_synset_function :memberMeronyms
	def_synset_function :stuffMeronyms
	def_synset_function :portionMeronyms
	def_synset_function :componentMeronyms
	def_synset_function :featureMeronyms
	def_synset_function :phaseMeronyms
	def_synset_function :placeMeronyms

	def_synset_function :holonyms
	def_synset_function :memberHolonyms
	def_synset_function :stuffHolonyms
	def_synset_function :portionHolonyms
	def_synset_function :componentHolonyms
	def_synset_function :featureHolonyms
	def_synset_function :phaseHolonyms
	def_synset_function :placeHolonyms

	def_synset_function :domains
	def_synset_function :categoryDomains
	def_synset_function :regionDomains
	def_synset_function :usageDomains

	def_synset_function :members
	def_synset_function :categoryMembers
	def_synset_function :regionMembers
	def_synset_function :usageMembers


end # module EN
end # module Linguistics
