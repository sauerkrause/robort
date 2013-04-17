(in-package :user-commands)

(defun quit (msg connection)
  (progn 
    (sb-ext:exit)))

;;(setf (gethash "quit" *registered-commands*)
;;      (lambda (msg connection)
;;	(cl-user:exit)))
