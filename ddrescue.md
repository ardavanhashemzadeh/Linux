# Using ddrescue to image a faulty drive

## First Pass
Take an image of what you can

ddrescue /dev/*** hdimage.img rescue.log

## Second Pass
Take try to recover the rest

ddrescue -d -r3 /dev/*** hdimage.img rescue.log
