#encoding: utf-8
require_relative 'spec_helper'

describe StanfordCoreNLP do
  before(:each) do
    StanfordCoreNLP.jvm_args = ['-Xms2G', '-Xmx2G']
    StanfordCoreNLP.use :spanish
    StanfordCoreNLP.model_files = {}
    StanfordCoreNLP.custom_properties['tokenize.language'] = 'es'
    StanfordCoreNLP.custom_properties['pos.model'] = 'edu/stanford/nlp/models/pos-tagger/spanish/spanish.tagger'
    StanfordCoreNLP.custom_properties['ner.model'] = 'edu/stanford/nlp/models/ner/spanish.ancora.distsim.s512.crf.ser.gz'
    StanfordCoreNLP.custom_properties['ner.applyNumericClassifiers'] = 'false'
    StanfordCoreNLP.custom_properties['useSUTime'] = 'false'
    StanfordCoreNLP.custom_properties['parse.model'] = 'edu/stanford/nlp/models/lexparser/spanishPCFG.ser.gz'
    # StanfordCoreNLP.set_model('pos.model', 'spanish.tagger')
    StanfordCoreNLP.default_jars = [
      'joda-time.jar',
      'xom.jar',
      'stanford-corenlp.jar',
      'stanford-corenlp-models.jar',
      'stanford-spanish-corenlp-models.jar',
      'jollyday.jar',
      'bridge.jar'
    ]
  end

  context "when the whole pipeline is run on an Spanish text" do
    it "should get the correct sentences, tokens, POS tags, lemmas and syntactic tree" do
      text = 'En un lugar de la Mancha, de cuyo nombre no quiero acordarme...'
      pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner)
      text = StanfordCoreNLP::Annotation.new(text)
      pipeline.annotate(text)

      sentences, tokens, tags, lemmas, begin_char, last_char, name_tags = *get_information(text, true, true)

      sentences.should eql ['En un lugar de la Mancha, de cuyo nombre no quiero acordarme...']
      tokens.should eql %w[En un lugar de la Mancha , de cuyo nombre no quiero acordar me ...]
      lemmas.should eql %w[en un lugar de la mancha , de cuyo nombre no quiero acordar I ...]
      tags.should eql %w[sp000 di0000 nc0s000 sp000 da0000 np00000 fc sp000 pr000000 nc0s000 rn vmip000 vmn0000 pp000000 fs]
      begin_char.should eql [0, 3, 6, 12, 15, 18, 24, 26, 29, 34, 41, 44, 51, 51, 60]
      last_char.should eql [2, 5, 11, 14, 17, 24, 25, 28, 33, 40, 43, 50, 60, 60, 63]
      name_tags.should eql %w[O O O O O OTROS O O O O O O O O O]
    end
  end
end