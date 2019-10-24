;;; bento.el --- the bento code checker      -*- lexical-binding: t; -*-

;; Copyright (C) 2019 r2c

;; Author: Ash Zahlen <ash@returntocorp.com>
;; License: GPLv3
;; URL: https://github.com/returntocorp/bento-emacs
;; Version: 0.0.1
;; Package-Version: 0.0.1
;; Package-Requires: ((flycheck "0.22") (emacs "25") (f "0.20"))

;; This file is not part of GNU Emacs.

;;; Commentary:

;; bento is a code quality/productivity tool. This provides flycheck integration
;; with it. See https://pypi.org/project/bento-cli/.

;;; Code:

(eval-when-compile (require 'subr-x))
(require 'f)
(require 'flycheck)
(require 'json)

(defun bento--parse-flycheck (output checker buffer)
  "Parse OUTPUT as bento JSON.

CHECKER and BUFFER are supplied by Flycheck and indicate the checker that ran
and the buffer that were checked."
  (when-let ((buffer-path (buffer-file-name buffer))
             (bento-dir (bento--find-base-dir buffer-path))
             (findings (bento--findings-for-path output
                                                 (f-relative buffer-path bento-dir))))
             (mapcar (apply-partially 'bento--finding-to-flycheck checker buffer)
                     findings)))

(defun bento--findings-for-path (output path)
  "Select out the findings in OUTPUT whose path is PATH."
  (car (flycheck-parse-json output)))


(defun bento--finding-to-flycheck (checker buffer finding)
  "Convert FINDING into a Flycheck error found by CHECKER in BUFFER.

Note that this will set the buffer even for errors that occurred in other files.
The error-filter will filter that out later."
  (let-alist finding
    (flycheck-error-new-at
     .line
     .column
     (pcase .severity
       (1 'warning)
       (2 'error)
       (_ 'error))
     .message
     :id .check_id
     :checker checker)))

(defun bento--find-base-dir (path)
  "Starting from the directory containing PATH, find the first .bento.yml file."
  (if path
      (when-let (dir (f-dirname path))
        (if (f-exists? (f-join dir ".bento.yml"))
            dir
          (bento--find-base-dir dir)))
    nil))

(flycheck-define-checker bento
  "Multi-language checker using Bento."
  :command ("bento" "check" "--formatter" "json" source-inplace)
  :error-parser bento--parse-flycheck
  :modes (python-mode js-mode js2-mode js-jsx-mode))

(provide 'bento)
;;; bento.el ends here
