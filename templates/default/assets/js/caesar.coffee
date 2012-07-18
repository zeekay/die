quotes = [
  "Veni, vidi, vici."
  "Gallia est omnis divisa in partes tres."
  "Horum omnium fortissimi sunt Belgae."
  "Fere libenter homines id quod volunt credunt."
  "Alea iacta est."
  "Galia est pacata."
  "Sed fortuna, quae plurimum potest cum in reliquis rebus tum praecipue in bello, parvis momentis magnas rerum commutationes efficit; ut tum accidit."
]

exports.quote = ->
  idx = Math.floor Math.random() * quotes.length
  return quotes[idx]
