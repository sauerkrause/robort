(in-package :user-commands)

(require :cl-ppcre)

(defun tinyurl-for (url)
  (let ((req-url "http://tinyurl.com/api-create.php"))
    (print req-url)
    (drakma:http-request req-url :method :post
			 :parameters `(("url" . ,url)))))

(defun extract-argument (msg)
  (user-command-helpers::split-by-one-space (cadr (irc:arguments msg))))

(require :drakma)
(require :cl-html5-parser)
(require :do-urlencode)

(defun find-all-in-tree (element name)
  (let ((ret ()))
    (labels ((collect (elmt name)
                      (if element
                          (dolist (child (html5-parser::%node-child-nodes elmt))
                            (if (equal (html5-parser:node-name child) name)
                                (progn (print child)
				       (push child ret)))
                            (collect child name)))))
            (collect element name))
    (nreverse ret)))
(defun null-safify (fn)
  (lambda (element)
    (if element
	(funcall fn element))))

(defun extract-tag (tag body)
  (let ((document (html5-parser:parse-html5 body)))
    (let ((titles (mapcar (null-safify #'html5-parser:node-value)
			  (mapcar #'html5-parser:node-first-child
				  (find-all-in-tree document tag)))))
      (if (> (length titles) 0)
	  (car titles)))))
(defun extract-meta-element (body)
  (let ((metas (extract-tag "meta" body)))
    (let ((descriptions (remove-if-not #'extract-meta-description metas)))
      (if descriptions (car descriptions)))))

(defun extract-meta-description (meta)
  (if meta 
      (let ((name (html5-parser:element-attribute meta "name"))
	    (content (html5-parser:element-attribute meta "content")))
	(if (and name
		 content
		 (equalp name "DESCRIPTION"))
	    content))))

(labels ((get-title (body)
		    (extract-tag "title" body))
	 (get-description (body)
			  (extract-meta-element body)))
	(defun preview-url (url longurl)
	  ;; Go ahead and request the longurl for its body.
	  (let* ((urlbody (drakma:http-request longurl))
		 (title (get-title urlbody))
		 (description (get-description urlbody)))
	    (format nil "~@[~A~]~@[ (~A)~]~@[: ~A~]" url title description))))

(defun tinyurl (msg connection)
  (let* ((longurl (elt (extract-argument msg) 1))
	 (url (tinyurl-for longurl)))
    (print url)
    (irc:privmsg connection
		 (get-destination msg)
		 (if url 
		     (preview-url url longurl)
		   (format nil "Bogus url")))))
