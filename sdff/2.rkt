#lang racket

; TODO : generalize the combinators with respect to inputs

(define (compose f g)
  (let ((n (procedure-arity g))
        (m (procedure-result-arity g)))
    (define (the-composition . args)
      (unless (= (length args) n)
        (error "Input arity mismatch"))
      (unless (= m 1)
        (error "Second procedure result arity mismatch"))
      (f (apply g args)))
    (procedure-reduce-arity the-composition n)))

(define (generalized-compose f g)
  (define (the-composition . args)
    (call-with-values (lambda () (apply g args)) f))
  (procedure-reduce-arity the-composition (procedure-arity g)))

(define ((iterate n) f)
  (if (= n 0)
    identity
    (compose f ((iterate (- n 1)) f))))

(define (parallel-combine f g h)
  (let ((n (procedure-arity f))
        (m (procedure-arity g))
        (o (procedure-arity h))
        (n1 (procedure-result-arity f))
        (m1 (procedure-result-arity g))
        (o1 (procedure-result-arity h)))
    (unless (= m n)
      (error "Procedures' arities aren't equal"))
    (unless (= m1 n1)
      (error "Procedures' return arities aren't equal"))
    (unless (= 1 n1)
      (error "First procedure doesn't have return arity 1"))
    (unless (= 1 m1)
      (error "Second procedure doesn't have return arity 1"))
    (unless (= 2 o)
      (error "Third procedure doesn't have arity 2"))
    (define (the-combination . args)
      (unless (= (length args) n)
        (error "Input arity mismatch"))
      (h (apply f args) (apply g args)))
    (procedure-reduce-arity the-combination o1)))

(define (spread-combine f g h)
  (let ((n (procedure-arity f)) (m (procedure-arity g)))
    (let ((t (+ n m)))
      (define (the-combination . args)
        (unless (= (length args) t)
          (error "Arity mismatch"))
        (h (apply f (take args n))
           (apply g (drop args n))))
      (procedure-reduce-arity the-combination t))))

(define (spread-apply f g)
  (let ((n (procedure-arity f))
        (m (procedure-arity g)))
    (let ((t (+ n m)))
      (define (the-combination . args)
        (unless (= (length args) t)
          (error "Input arity mismatch"))
        (values (apply f (take args n))
                (apply g (drop args n))))
      (procedure-reduce-arity the-combination t))))