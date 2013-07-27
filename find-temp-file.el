;;; find-temp-file.el --- Open quickly a temporary file

;; Copyright (C) 2012-2013 Sylvain Rousseau <thisirs at gmail dot com>

;; Author: Sylvain Rousseau <thisirs at gmail dot com>
;; Maintainer: Sylvain Rousseau <thisirs at gmail dot com>
;; URL:
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This library allows you to open quickly a temporary file of a given
;; extension. No need to specify a name, just an extension.

;;; Installation:

;; Just put this file in your load path and require it:
;; (require 'find-temp-file)

;; You may want to bind `find-temp-file' to a convenient keystroke. In
;; my setup, I bind it to "C-x C-t".

;;; Code

(require 'format-spec)

(defvar find-temp-file-directory "/tmp/"
  "Directory where temporary files are created.")

(defvar find-temp-file-prefix
  '("alpha" "bravo" "charlie" "delta" "echo" "foxtrot" "golf" "hotel"
    "india" "juliet" "kilo" "lima" "mike" "november" "oscar" "papa"
    "quebec" "romeo" "sierra" "tango" "uniform" "victor" "whiskey"
    "x-ray" "yankee" "zulu")
  "Successive names of temporary files.")

(defvar find-temp-template-alist
  '(("m" . "%N_%S.%E"))
  "Alist with file extensions and corresponding file name
template.

%N: prefix taken from `find-temp-file-prefix'
%S: shortened sha-1 of the extension
%E: extension")

(defvar find-temp-template-default
  "%N-%S.%E"
  "Default template for temporary files.")

;;;###autoload
(defun find-temp-file (extension)
  "Open a file temporary file.

EXTENSION is the extension of the temporary file. If EXTENSION
contains a dot, use EXTENSION as the full file name."
  (interactive
   (let* ((default (concat (if buffer-file-name
                               (file-name-extension
                                buffer-file-name))))
          (default-prompt (if (equal default "") ""
                            (format " (%s)" default)))
          choice)
     (setq choice
           (read-string
            (format "Extension%s: " default-prompt)))
     (list (if (equal "" choice)
               default
             choice))))
  (setq extension (or extension ""))
  (find-file (if (memq ?. (string-to-list extension))
                 (expand-file-name extension find-temp-file-directory)
               (find-temp-file--filename extension)))
  (basic-save-buffer))

(defun find-temp-file--filename (&optional extension)
  "Return a full path of a temporary file to be opened."
  (let* ((template
          (or
           (and extension
                (assoc-default extension find-temp-template-alist 'string-match))
           find-temp-template-default))
         (file-template
          (format-spec
           template
           `((?E . ,extension)
             (?S . ,(substring (sha1 extension) 0 5))
             (?N . "%N")))))
    (catch 'found
      (mapc (lambda (prefix)
              (let* ((file-name (format-spec
                                 file-template
                                 `((?N . ,prefix))))
                     (file-path (expand-file-name file-name find-temp-file-directory)))
                (unless (file-exists-p file-path)
                  (throw 'found file-path))))
            find-temp-file-prefix))))

(provide 'find-temp-file)

;;; find-temp-file.el ends here
