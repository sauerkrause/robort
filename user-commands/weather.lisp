(in-package :user-commands)

(require :rss)

(defun rss-items (url)
  (let ((ret (rss:rss-site url)))
    (if ret
	(rss:items ret))))

(defun rss-titles (url)
  (mapcar #'rss:title (rss-items url)))

(defun rss-newest-title (url)
  (let ((titles (rss-titles url)))
    (if (and titles (consp titles))
	(car titles)
      (format nil "No weather found for ~A" url))))

(defun weather-for (airport)
  (let ((rss-url (format nil "http://w1.weather.gov/xml/current_obs/~A.rss" airport)))
    (rss-newest-title rss-url)))

(defun weather (msg connection)
  (irc:privmsg connection
	       (get-destination msg)
	       (weather-for
		(car (rest-words (cadr (irc::arguments msg)))))))
(export 'weather)