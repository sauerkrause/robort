(load "common-defs.lisp")

;; Need to know at least nick and serv
(defparameter *login*
  (make-login-info
   :nick "robort"
   :server "irc.tamu.edu"))

;; set of channels
(defparameter *channels* ())
(pushnew "#bottest2" *channels* :test #'equal)
(pushnew "#bottest" *channels* :test #'equal)
