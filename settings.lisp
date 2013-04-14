(load "common-defs.lisp")

;; Need to know at least nick and serv
(defparameter *login*
  (make-login-info
   :nick "robort"
   :server "irc.drwilco.net"))

;; set of channels
(defparameter *channels* ())
(pushnew "#bottest" *channels* :test #'equal)
