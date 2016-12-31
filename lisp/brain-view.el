;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; brain-view.el -- Tree views and buffers
;;
;; Part of the Brain-mode package for Emacs:
;;   https://github.com/joshsh/brain-mode
;;
;; Copyright (C) 2011-2016 Joshua Shinavier and collaborators
;;
;; You should have received a copy of the GNU General Public License
;; along with this software.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'brain-env)


;; unused colors: black/gray, orange
(defconst sharability-base-colors  '("#660000" "#604000" "#005000" "#000066"))
(defconst sharability-bright-colors  '("#D00000" "#D0B000" "#00B000" "#0000D0"))
(defconst sharability-reduced-colors '("red" "red" "blue" "blue"))
(defconst inference-base-colors '("#660066" "#006666"))
(defconst inference-bright-colors '("#FF00FF" "#00FFFF"))

(defvar brain-view-full-colors-supported (> (length (defined-colors)) 8))

(defun color-part-red (color)
  (string-to-number (substring color 1 3) 16))

(defun color-part-green (color)
  (string-to-number (substring color 3 5) 16))

(defun color-part-blue (color)
  (string-to-number (substring color 5 7) 16))

(defun color-string (red green blue)
  (concat "#" (format "%02X" red) (format "%02X" green) (format "%02X" blue)))

(defun weighted-average (a b weight)
  (+ (* a (- 1 weight)) (* b weight)))

(defun fade-color (color weight)
  (let ((low (weighted-average color 255 0.9375))
        (high color))
    (weighted-average low high weight)))

(defun atom-color (weight sharability bright has-meta)
  (let ((s
         (if (brain-env-using-inference)
             (elt (if bright inference-bright-colors inference-base-colors) (if has-meta 0 1))
           (elt (if bright sharability-bright-colors sharability-base-colors) (- (ceiling (* sharability 4)) 1)))))
    (color-string
     (fade-color (color-part-red s) weight)
     (fade-color (color-part-green s) weight)
     (fade-color (color-part-blue s) weight))))

(defun colorize (text weight sharability priority-bg priority-fg bright has-meta)
  (let ((color (if brain-view-full-colors-supported
                   (atom-color weight sharability bright has-meta)
                 (elt sharability-reduced-colors (- (ceiling (* sharability 4)) 1)))))
    (setq l (list
             :foreground color
             ;;:weight 'bold
             :underline (if (and priority-fg (> priority-fg 0))
                            (list :color (atom-color priority-fg sharability bright has-meta)) nil)
             :box (if priority-bg (list
                                   :color (atom-color priority-bg sharability bright has-meta)) nil)))
    (propertize text 'face l)))

(defun light-gray ()
  (if brain-view-full-colors-supported
    (list :foreground "grey80" :background "white")
    (list :foreground "black")))

(defun make-light-gray (text)
  (propertize text
              'face (light-gray)))

(defun delimit-value (value)
  (let ((s (string-match "\n" value)))
    (if s (let ((content (concat "\n" value "\n")))
            (concat "{{{"
                    (if (brain-env-context-get 'minimize-verbatim-blocks) (propertize content 'invisible t) content)
                    "}}}")) value)))

(defun write-view (children tree-indent)
  (loop for json across children do
        (let (
              (link (brain-env-json-get 'link json))
              (children (brain-env-json-get 'children json)))
          (let ((focus-id (brain-data-atom-id json))
                (focus-value (let ((v (brain-data-atom-value json))) (if v v "")))
		        (focus-weight (brain-data-atom-weight json))
		        (focus-sharability (brain-data-atom-sharability json))
		        (focus-priority (brain-data-atom-priority json))
                (focus-has-children (not (equal json-false (brain-env-json-get 'hasChildren json))))
		        (focus-alias (brain-data-atom-alias json))
		        (focus-shortcut (brain-data-atom-shortcut json))
		        (focus-meta (brain-data-atom-meta json)))
            (if focus-id
              (puthash focus-id json (brain-env-context-get 'atoms-by-id))
              (error "missing focus id"))
            (setq space "")
            (loop for i from 1 to tree-indent do (setq space (concat space " ")))
            (let ((line "") (id-infix (brain-view-create-id-infix focus-id)))
              (setq line (concat line space))
              (let ((bullet (if focus-has-children "+" "\u00b7"))) ;; previously: "-" or "\u25ba"
                (setq line (concat line
                                   (colorize bullet
                                             focus-weight focus-sharability focus-priority nil focus-alias focus-meta)
                                   id-infix
                                   " "
                                   (colorize (delimit-value focus-value)
                                             focus-weight focus-sharability nil focus-priority focus-alias focus-meta)
                                   "\n")))
              (insert (propertize line 'id focus-id)))
            (if (brain-env-using-inference)
                (loop for a across focus-meta do (insert (make-light-gray (concat space "    @{" a "}\n")))))
            (if (brain-env-context-get 'view-properties)
              (let ()
                (insert (make-light-gray
                         (concat space "    @sharability " (number-to-string focus-sharability) "\n")))
                (insert (make-light-gray
                         (concat space "    @weight      " (number-to-string focus-weight) "\n")))
                (if focus-priority
                    (insert (make-light-gray (concat space "    @priority    " (number-to-string focus-priority) "\n"))))
                (if focus-shortcut
                    (insert (make-light-gray (concat space "    @shortcut    " focus-shortcut "\n"))))
                (if focus-alias
                    (insert (make-light-gray (concat space "    @alias       " focus-alias "\n"))))))
            (write-view children (+ tree-indent 4))))))

(defun num-or-nil-to-string (n)
  (if n (number-to-string n) "nil"))

(defun view-info ()
  (concat
   "(root: " (brain-env-context-get 'root-id)
   " :height " (num-or-nil-to-string (brain-env-context-get 'height))
   " :style " (brain-env-context-get 'style)
   " :sharability
             [" (num-or-nil-to-string (brain-env-context-get 'min-sharability))
   ", " (num-or-nil-to-string (brain-env-context-get 'default-sharability))
   ", " (num-or-nil-to-string (brain-env-context-get 'max-sharability)) "]"
   " :weight
             [" (num-or-nil-to-string (brain-env-context-get 'min-weight))
   ", " (num-or-nil-to-string (brain-env-context-get 'default-weight))
   ", " (num-or-nil-to-string (brain-env-context-get 'max-weight)) "]"
   " :value \"" (brain-env-context-get 'title) "\")")) ;; TODO: actually escape the title string

(defun shorten-title (str maxlen)
  (if (> (length str) maxlen)
    (concat (substring str 0 maxlen) "...")
    str))

(defun name-for-view-buffer (root-id payload)
  (let ((title (brain-env-json-get 'title payload)))
    (if root-id
      (concat (shorten-title title 20) " [" root-id "]")
      title)))

(defun switch-to-buffer-with-context (name context)
  "activate Brain-mode in a new view buffer created by Brain-mode"
  (switch-to-buffer name)
  (setq buffer-read-only nil)
  (brain-mode)
  (brain-env-set-context context))

(defun read-string-value (context-variable payload-variable payload)
  (let ((value (brain-env-json-get payload-variable payload)))
    (if value (brain-env-context-set context-variable value))))

(defun read-numeric-value (context-variable payload-variable payload)
  (let ((value (brain-env-json-get payload-variable payload)))
    (if value (brain-env-context-set context-variable (string-to-number value)))))

(defun find-default-sharability (root-sharability)
  (min brain-const-sharability-public root-sharability))

(defun configure-context (payload)
  "Sets variables of the buffer-local context according to a service response"
  (let ((view (brain-data-payload-view payload)))
    (read-string-value 'root-id 'root payload)
    (read-string-value 'style 'style payload)
    (read-string-value 'title 'title payload)
    (read-numeric-value 'height 'height payload)
    (read-numeric-value 'min-sharability 'minSharability payload)
    (read-numeric-value 'max-sharability 'maxSharability payload)
    (brain-env-context-set 'default-sharability (find-default-sharability (brain-data-atom-sharability view)))
    ;;(read-numeric-value 'default-sharability 'defaultSharability payload)
    (read-numeric-value 'min-weight 'minWeight payload)
    (read-numeric-value 'max-weight 'maxWeight payload)
    (read-numeric-value 'default-weight 'defaultWeight payload)))

(defun brain-view-set-context-line (&optional line)
  (brain-env-context-set 'line
    (if line line (line-number-at-pos))))

;; Try to move to the corresponding line in the previous view.
;; This is not always possible and not always helpful, but it is often both.
(defun move-to-context-line ()
  (let ((line (brain-env-context-get 'line)))
    (if line
      (beginning-of-line line)
      (error "no line number"))))

(defun create-atom-hashtable ()
  (brain-env-context-set 'atoms-by-id (make-hash-table :test 'equal)))

;; always include line numbers in views
(defun show-line-numbers ()
  (linum-mode t))

(defun is-readonly ()
  (or (brain-env-is-readonly)
    (brain-env-in-search-mode)))

(defun configure-buffer ()
  (if (not (brain-env-context-get 'truncate-long-lines)) (toggle-truncate-lines))
  (beginning-of-buffer)
  (setq visible-cursor t)
  (move-to-context-line)
  (setq buffer-read-only (is-readonly))
  (show-line-numbers))

(defun write-to-buffer (payload)
  (write-view (brain-env-json-get 'children (brain-data-payload-view payload)) 0))

(defun brain-view-open (payload context)
  "Callback to receive and display the data of a view"
  (switch-to-buffer-with-context
     (name-for-view-buffer (brain-data-atom-id (brain-data-payload-view payload)) payload) context)
  (configure-context payload)
  (create-atom-hashtable)
  (erase-buffer)
  (write-to-buffer payload)
  (configure-buffer))

(defun brain-view-color-at-min-sharability ()
  "Returns the color for at atom at the minimum visible sharability"
  (atom-color 0.75 (+ 0.25 (brain-env-context-get 'min-sharability)) nil nil))

(defun brain-view-create-id-infix (id)
  "Creates a string of the form :0000000:, where 000000 is the id of an atom"
  (propertize (concat " :" id ":") 'invisible t))


(provide 'brain-view)
