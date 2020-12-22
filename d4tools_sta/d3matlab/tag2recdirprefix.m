function    [recdir,prefix] = tag2recdirprefix(tag)
%
%     [recdir,prefix] = tag2recdirprefix(tag)
%      Convert a tag deployment name to a D3 style
%      recdir-prefix pair. This assumes that the tagpath to 
%      the audio files is set using settagpath. The following 
%      directory structure is assumed:
%      <gettagpath('AUDIO')>/tag(1:4)/tag
%      Example:
%      If the audio path is 'f:/data' and the tag is 'hp14_226b',
%      this function will return:
%      recdir = 'f:/data/hp14/hp14_226b'
%      prefix = 'hp14_226b'

recdir = [gettagpath('AUDIO') '/' tag(1:4) '/' tag] ;
prefix = tag ;
