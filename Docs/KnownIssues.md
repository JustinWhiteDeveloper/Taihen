# Known Issues

Below is a list of known issues in no particular order.

### Generic
* Only the first dictionary match is shown. This can cause inconvience particularly if in certain verb deconjugation situations, highlighting multiple words and so on.
* When loading large files, the scroll bar can take some time to load properly.
* It takes a long time to add new dictionaries.
* Occasional bugs with anki searching, especially in very unique Anki setups
* The audio source is from a third party and no redudancy is programmed if that website goes down, words are not available.
* Occasional lagging due to blocking the main thread. These are being worked through.


### Dictionaries
* Currently only Yomichan folder format is available, this likely causes issues outside of Japanese and might require users to download Yomichan to convert dictionaries to this format.
* Yomichan format likely only supports Japanese. This was a oversight.

### Japanese
* Various deconjugation issues from the deconjugator. There is plans to use a neural network from the Spreedsheet data that is currently used to generate the existing solution.
