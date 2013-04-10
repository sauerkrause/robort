
;; (defun connect (&key (nickname *default-nickname*)
;;                      (username nil)
;;                      (realname nil)
;;                      (password nil)
;;                      (mode 0)
;;                      (server *default-irc-server*)
;;                      (port :default)
;;                      (connection-type 'connection)
;;                      (connection-security :none)
;;                      (logging-stream t))
;;   "Connect to server and return a connection object.

;; `port' and `connection-security' have a relation: when `port' equals
;; `:default' `*default-irc-server-port*' is used to find which port to
;; connect to.  `connection-security' determines which port number is found.

;; `connection-security' can be either `:none' or `:ssl'.  When passing
;; `:ssl', the cl+ssl library must have been loaded by the caller.
;; "

(load "login-info.cl")

;; Need to know at least nick and serv
(defparameter *login*
  (make-login-info
   :nick "robort"
   :server "irc.tamu.edu"))

(defparameter *servers*
  '("#bottest"))
