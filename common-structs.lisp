(defstruct login-info nick server)
;; condition saying that this should reload.
(define-condition reload-required (error) ())
