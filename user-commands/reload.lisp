(in-package :user-commands)

(defun reload (msg connection)
  (progn
    (format T "msg: ~a" msg)
    (print "Reloading")
    (robort:reinitialize connection)))
