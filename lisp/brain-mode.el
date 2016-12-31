;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; brain-mode.el -- Extend-o-Brain client and user interface
;; This major mode allows you to view, edit, search, and process an Extend-o-Brain personal knowledge base.
;;
;; Part of the Brain-mode package for Emacs:
;;   https://github.com/joshsh/brain-mode
;;
;; Dependencies:
;;
;;     aes, indent-guide, json, latex-math-preview, and linum
;;
;; Required global variables:
;;
;;     brain-server-url: IP and port Gremlin Server (defaults to "http://localhost:8182")
;;
;; See brain-mode-init-example.el for optional variables and example values.
;;
;; Copyright (C) 2011-2016 Joshua Shinavier and collaborators
;;
;; You should have received a copy of the GNU General Public License
;; along with this software.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; for JSON-formatted messages to and from Semantic Synchrony services (see json-read-from-string, json-encode)
(require 'json)

;; for line number annotations in buffers (see linum-mode)
(require 'linum)

;; for visiting URLs in a browser (see goto-address-at-point)
(require 'goto-addr)

;; for encryption of sensitive values
(require 'aes)

;; for LaTeX views (nice-to-have, but not essential)
(require 'latex-math-preview)

;; a visual aid to consistent indentation
(require 'indent-guide)

(require 'brain-client)
(require 'brain-commands)
(require 'brain-data)
(require 'brain-env)
(require 'brain-view)
(require 'brain-wrapper)

(defvar brain-mode-syntax-table nil
  "Syntax table used while in Brain-mode.")
(if brain-mode-syntax-table ()
  (setq brain-mode-syntax-table (make-syntax-table)))

(defvar brain-mode-abbrev-table nil
  "Abbrev table used while in Brain-mode.")
(define-abbrev-table 'brain-mode-abbrev-table ())

(defun set-indent-guide-mode ()
  (indent-guide-mode)
  (setq indent-guide-recursive t)
  (set-face-foreground 'indent-guide-face "gray"))

(defun brain-mode ()
  "Major mode for interacting with an Extend-o-Brain personal knowledge base"
  (interactive)
  (kill-all-local-variables)
  (use-local-map brain-mode-map)
  (brain-env-define-buffer-local-variables)
  (setq local-abbrev-table brain-mode-abbrev-table)
  (set-syntax-table brain-mode-syntax-table)
  ;; note: not customizing indent style with indent-line-function
  (setq mode-name "Brain-mode")
  (setq major-mode 'brain-mode)
  (set-indent-guide-mode)
  (run-hooks 'brain-hook))


(provide 'brain-mode)
