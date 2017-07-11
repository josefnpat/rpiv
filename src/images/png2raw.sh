#convert $1 -unique-colors txt:-

convert $1 txt:- | tail -n +2
