(in-package :user-commands)

(require :cl-ppcre)

(defun tinyurl-for (url)
  (let ((req-url "http://tinyurl.com/api-create.php"))
    (drakma:http-request req-url :method :post
			 :parameters `(("url" . ,url)))))

(defun extract-argument (msg)
  (user-command-helpers::split-by-one-space (cadr (irc:arguments msg))))
(require :drakma)
(require :cl-html5-parser)
(require :do-urlencode)

(defun tinyurl-for (url)
  (let ((req-url "http://tinyurl.com/api-create.php"))
    (drakma:http-request req-url :method :post
			 :parameters `(("url" . ,url)))))

(defun find-all-in-tree (element name)
  (let ((ret ()))
    (labels ((collect (elmt name)
                      (if element
                          (dolist (child (html5-parser::%node-child-nodes elmt))
                            (if (equal (html5-parser:node-name child) name)
                                (progn (push child ret)))
                            (collect child name)))))
            (collect element name))
    (nreverse ret)))

(defun null-safify (fn)
  (lambda (element)
    (if element
	(funcall fn element))))

(defun extract-tags (tag body)
  (let ((document (html5-parser:parse-html5 body)))
    (let ((titles (mapcar #'html5-parser:node-first-child
				  (find-all-in-tree document tag))))
      titles)))

(defun extract-tag (tag body)
  (let ((titles (extract-tags tag body)))
      (if titles 
	  (html5-parser:node-value (car titles)))))

(defun extract-meta-description (meta)
  (if meta 
      (let ((name (html5-parser:element-attribute meta "name"))
	    (content (html5-parser:element-attribute meta "content")))
	(format t "name: ~A~%content: ~A~%" name content)
	(if (and name
		 content
		 (equalp name "DESCRIPTION"))
	    content))))

(defun extract-meta-element (body)
  (let ((document (html5-parser:parse-html5 body)))
    (let ((metas (find-all-in-tree document "meta")))
      (let ((descriptions (remove-if-not #'extract-meta-description metas)))
	(format t "Metas: ~A~%Descriptions: ~A~%" metas descriptions)
	(if descriptions (car descriptions))))))

(labels ((get-title (body)
		    (extract-tag "title" body))
	 (get-description 
	  (body)
	  (extract-meta-description 
	   (extract-meta-element body))))
	(defun preview-url (url longurl)
	  ;; Go ahead and request the longurl for its body.
	  (multiple-value-bind (urlbody junk headers) (drakma:http-request longurl :preserve-uri t :user-agent :safari)
			       (print headers)
			       (print (assoc :content-type headers))
			       (let ((content-type (cdr (assoc :content-type headers))))
				 (if (search "html" content-type)
				     (let ((title (get-title urlbody))
					   (description (get-description urlbody)))
				       (format nil "~@[~A~]~@[ (~A)~]~@[: ~A~]" url title description))
				   (format nil "~@[~A~]" url))))))

(defun tinyurl (msg connection)
  (let* ((longurl (elt (extract-argument msg) 1))
	 (url (tinyurl-for longurl)))
    (print url)
    (irc:privmsg connection
		 (get-destination msg)
		 (if url 
		     (preview-url url longurl)
		   (format nil "Bogus url")))))
