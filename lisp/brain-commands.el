;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; brain-commands.el -- Top-level commands and key bindings
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
(require 'brain-data)
(require 'brain-view)
(require 'brain-client)


(defconst fast-numbers
  '(
    (?0 0) (?1 1) (?2 2) (?3 3) (?4 4) (?5 5) (?6 6) (?7 7) (?8 8) (?9 9)
    (?z 0) (?a 1) (?s 2) (?d 3) (?f 4) (?g 5) (?h 6) (?j 7) (?k 8) (?l 9) (?\; 10)))

(defconst line-addr-keypairs
 (list
  '(?0 ?0) '(?1 ?1) '(?2 ?2) '(?3 ?3) '(?4 ?4) '(?5 ?5) '(?6 ?6) '(?7 ?7) '(?8 ?8) '(?9 ?9)
  '(?\; ?0) '(?a ?1) '(?s ?2) '(?d ?3) '(?f ?4) '(?g ?5) '(?h ?6) '(?j ?7) '(?k ?8) '(?l ?9)
  '(?u ?1) '(?i ?2) '(?o ?3) '(?p ?4)))

(defvar line-addr-keymap (make-hash-table))

(dolist (pair line-addr-keypairs)
  (puthash (car pair) (car (cdr pair)) line-addr-keymap))

(defun assert-readwrite-context ()
  "Asserts that the current Brain-mode buffer is in a writable state"
  (if (brain-env-is-readonly)
    (brain-env-fail (concat "cannot update view in current mode: " (brain-env-context-get 'mode))) nil)
    (brain-env-succeed))

(defun brain-atom-info (selector)
  "display, in the minibuffer, information about an atom produced by SELECTOR"
  (lexical-let ((as selector))
    (lambda () (interactive)
      (let ((atom (funcall as)))
        (if atom
            (brain-data-show atom)
          (brain-env-error-no-focus))))))

;; note: the id doesn't stay invisible when you paste it, although it stays light gray
(defun brain-copy-focus-reference-to-clipboard ()
  "copy a reference to the atom at point to the system clipboard"
  (interactive)
  (let ((id (brain-data-atom-id-at-point)))
    (if id
        (copy-to-clipboard (concat "*" (brain-view-create-id-infix id)))
      (brain-env-error-no-focus))))

(defun brain-copy-focus-value-to-clipboard ()
  "copy the value of the atom at point to the system clipboard"
  (interactive)
  (let ((value (brain-data-focus-value)))
    (if value
        (copy-to-clipboard value)
      (brain-env-error-no-focus))))

(defun brain-copy-root-reference-to-clipboard ()
  "copy a reference to the atom at point to the system clipboard"
  (interactive)
  (let ((id (brain-data-root-id)))
    (if id
        (copy-to-clipboard (concat "*" (brain-view-create-id-infix id)))
      (brain-env-error-no-root))))

(defun brain-debug ()
  "executes a debug action (by default a no-op)"
  (interactive)
  (brain-env-debug-message (concat "current mode: " (brain-env-context-get 'mode))))

(defun brain-duplicates ()
  "retrieve a list of atoms with duplicate values"
  (interactive)
  (brain-client-fetch-duplicates))

(defun brain-enter-readwrite-view ()
  "enter edit (read/write) mode in the current view"
  (interactive)
  (if (and (brain-env-in-treeview-mode) (brain-env-is-readonly)) (progn
    (brain-env-set-readonly nil)
    (brain-client-refresh-view))))

(defun brain-enter-readonly-view ()
  "enter read-only mode in the current view"
  (interactive)
  (if (and (brain-env-in-treeview-mode) (not (brain-env-is-readonly))) (progn
    (brain-env-set-readonly t)
    (brain-client-refresh-view))))

(defun brain-events ()
  "retrieve the Extend-o-Brain event stack (e.g. notifications of gestural events), ordered by decreasing time stamp"
  (interactive)
  (brain-client-fetch-events 2))

(defun brain-export-vcs (file)
  "export graph as version-controlled directory"
  (interactive)
  (brain-env-info-message (concat "exporting VCS dump to " file))
  (brain-client-export "VCS" file))

(defun brain-export-edges (file)
  "export tab-separated dump of Extend-o-Brain parent-child edges to the file system"
  (interactive)
  (brain-env-info-message (concat "exporting edges to " file))
  (brain-client-export "Edges" file))

(defun brain-export-graphml (file)
  "export a GraphML dump of the knowledge base to the file system"
  (interactive)
  (brain-env-info-message (concat "exporting GraphML to " file))
  (brain-client-export "GraphML" file))

(defun brain-export-latex (file)
  "export a LaTeX-formatted view of a subtree of the knowledge base to the file system"
  (interactive)
  (brain-env-info-message (concat "exporting LaTeX to " file))
  (brain-client-export "LaTeX" file))

(defun brain-export-pagerank (file)
  "export a tab-separated PageRank ranking of Extend-o-Brain atoms to the file system"
  (interactive)
  (brain-env-info-message (concat "computing and exporting PageRank to " file))
  (brain-client-export "PageRank" file))

(defun brain-export-rdf (file)
  "export an RDF dump of the knowledge base to the file system"
  (interactive)
  (brain-env-info-message (concat "exporting private N-Triples dump to " file))
  (brain-client-export "N-Triples" file))

(defun brain-export-vertices (file)
  "export tab-separated dump of Extend-o-Brain vertices (atoms) to the file system"
  (interactive)
  (brain-env-info-message (concat "exporting vertices to " file))
  (brain-client-export "Vertices" file))

(defun brain-import-vcs (file)
  "import a graph from a set of version-controlled directories into the knowledge base"
  (interactive)
  (brain-env-info-message (concat "importing version-controlleg graph from " file))
  (brain-client-import "VCS" file))

(defun brain-import-freeplane (file)
  "import one or more Freeplane files into the knowledge base"
  (interactive)
  (brain-env-info-message (concat "importing Freeplane nodes from " file))
  (brain-client-import "Freeplane" file))

(defun brain-import-graphml (file)
  "import a GraphML dump from the file system into the knowledge base"
  (interactive)
  (brain-env-info-message (concat "importing GraphML from " file))
  (brain-client-import "GraphML" file))

(defun brain-find-isolated-atoms ()
  "retrieve a list of isolated atoms (i.e. atoms with neither parents nor children) in the knowledge base"
  (interactive)
  (brain-client-fetch-find-isolated-atoms))

(defun brain-remove-isolated-atoms ()
  "remove all isolated atoms (i.e. atoms with neither parents nor children) from the knowledge base"
  (interactive)
  (brain-client-fetch-remove-isolated-atoms))

(defun brain-find-roots ()
  "retrieve a list of roots (i.e. atoms with no parents) in the knowledge base"
  (interactive)
  (brain-client-find-roots))

(defun brain-history ()
  "retrieve a list of the most recently viewed or updated atoms, in decreasing order of recency"
  (interactive)
  (brain-client-fetch-history))

(defun brain-infer-types ()
  "perform type inference on the Extend-o-Brain knowledge base, adding type annotations"
  (interactive)
  (brain-env-info-message "performing type inference")
  (brain-client-infer-types))

(defun brain-insert-attr-priority (expr)
  "insert a line to set the priority of an atom to the value given by EXPR"
  (interactive)
  (let ((n (number-shorthand-to-number expr)))
    (if n (insert (concat "\n                @priority " (number-to-string (/ n 4.0)) "\n")))))

(defun brain-insert-attr-sharability (expr)
  "insert a line to set the sharability of an atom to the value given by EXPR"
  (interactive)
  (let ((n (number-shorthand-to-number expr)))
    (if n (insert (concat "\n                @sharability " (number-to-string (/ n 4.0)) "\n")))))

(defun brain-insert-attr-weight (expr)
  "insert a line to set the weight of an atom to the value given by EXPR"
  (interactive)
  (let ((n (number-shorthand-to-number expr)))
    (if n (insert (concat "\n                @weight " (number-to-string (/ n 4.0)) "\n")))))

(defun brain-insert-current-date ()
  "insert the current date, in the format yyyy-mm-dd, into the current buffer"
  (interactive)
  (insert (brain-env-format-date (current-time))))

(defun brain-insert-current-time ()
  "insert the current time, in the format hh:mm, into the current buffer"
  (interactive)
  (insert (brain-env-format-time (current-time) nil)))

(defun brain-insert-current-time-with-seconds ()
  "insert the current time with seconds, in the format hh:mm:ss, into the current buffer"
  (interactive)
  (insert (brain-env-format-time (current-time) t)))

(defun brain-kill-other-buffers ()
  "Kill all other brain-mode buffers."
  (interactive)
  (mapc 'kill-buffer
	(my-filter
	 (lambda (bname)
	   (eq (buffer-local-value 'major-mode (get-buffer bname))
	       'brain-mode))
	 (delq (current-buffer) (buffer-list))
	 )))

(defun brain-preview-focus-latex-math ()
  "create a graphical preview of the value of the atom at point, which must be a LaTeX mathematical expression"
  (interactive)
  (end-of-line)
  (backward-word)
  (latex-math-preview-expression))

(defun brain-priorities ()
  "retrieve a list of atoms with nonzero priority values, ordered by decreasing priority"
  (interactive)
  (brain-client-fetch-priorities))

(defun brain-push-view ()
  "push an up-to-date view into the knowledge base"
  (interactive)
  (if (and (brain-env-in-treeview-mode) (assert-readwrite-context))
    (brain-client-push-view)))

(defun brain-ripple-query (query)
  "evaluate Ripple expression QUERY"
  (interactive)
  (if (> (length query) 0)
      (brain-client-fetch-ripple-results query)))

(defun brain-fulltext-query (query)
  "evaluate full-text query for QUERY, yielding a ranked list of query results in a new buffer"
  (interactive)
  (if (> (length query) 0)
    (brain-client-fetch-query query "FullText")))

(defun brain-acronym-query (query)
  "evaluate acronym (abbreviated fulltext) query for QUERY, yielding a ranked list of query results in a new buffer"
  (interactive)
  (if (> (length query) 0)
    (brain-client-fetch-query query "Acronym")))

(defun brain-shortcut-query (query)
  "evaluate shortcut query for QUERY, yielding query results (normally zero or one) in a new buffer"
  (interactive)
  (if (> (length query) 0)
    (brain-client-fetch-query query "Shortcut")))

(defun brain-set-min-sharability (expr)
  "set the minimum @sharability (for atoms visible in the current view) to the number represented by EXPR"
  (interactive)
  (if (brain-env-in-treeview-mode)
    (let ((n (number-shorthand-to-number expr)))
      (if n (brain-client-set-min-sharability (/ n 4.0))))))

(defun brain-set-min-weight (expr)
  "set the minimum @weight (for atoms visible in the current view) to the number represented by EXPR"
  (interactive)
  (if (brain-env-in-treeview-mode)
    (let ((n (number-shorthand-to-number expr)))
      (if n (brain-client-set-min-weight (/ n 4.0))))))

(defun brain-set-focus-priority (expr)
  "set the @priority of the atom at point to the number represented by EXPR"
  (interactive)
  (if (brain-env-in-treeview-mode)
    (let ((n (number-shorthand-to-number expr)))
      (if n (brain-client-set-focus-priority (/ n 4.0))))))

(defun brain-set-focus-sharability (expr)
  "set the @sharability of the atom at point to the number represented by EXPR"
  (interactive)
  (if (brain-env-in-treeview-mode)
    (let ((n (number-shorthand-to-number expr)))
      (if n (brain-client-set-focus-sharability (/ n 4.0))))))

(defun brain-set-focus-weight (expr)
  "set the @weight of the atom at point to the number represented by EXPR"
  (interactive)
  (if (brain-env-in-treeview-mode)
    (let ((n (number-shorthand-to-number expr)))
      (if n (brain-client-set-focus-weight (/ n 4.0))))))

(defun brain-set-value-truncation-length (length-str)
  "set the value truncation length to the number represented by LENGTH-STR.
Longer values are truncated, for efficiency and readability, when they appear in views.
A value of -1 indicates that values should not be truncated."
  (interactive)
  (let ((n (string-to-number length-str)))
    (brain-env-context-set 'value-length-cutoff n)))

(defun brain-set-view-height (expr)
  "set the height of the current view to the number of levels represented by EXPR"
  (interactive)
  (if (brain-env-in-treeview-mode)
    (let ((height (number-shorthand-to-number expr)))
      (if (brain-env-assert-height-in-bounds  height)
        (progn
          (brain-env-context-set 'height height)
          (brain-client-refresh-view))))))

(defun brain-toggle-emacspeak ()
  "turn Emacspeak on or off"
  (interactive)
  (dtk-toggle-quiet))

(defun brain-toggle-inference-viewstyle ()
  "toggle between the sharability view style and the type inference view style.
In the sharability view style, colors are assigned to atoms based on the sharability of each atom
(for example, private atoms are red, while public atoms are green).
However, in the type inference view style, an atom is either cyan or magenta depending on whether
a type has been assigned to it by the inference engine."
  (interactive)
  (if (brain-env-in-treeview-mode) (progn
    (brain-env-toggle-inference-viewstyle)
    (brain-update-view)
    (brain-env-info-message (concat "switched to " (brain-env-context-get 'view-style) " view style")))))

(defun brain-toggle-minimize-verbatim-blocks ()
  "enable or disable the hiding of the contents of {{{verbatim blocks}}}, which span multiple lines"
  (interactive)
  (if (brain-env-in-treeview-mode) (progn
    (brain-env-context-set 'minimize-verbatim-blocks (not (brain-env-context-get 'minimize-verbatim-blocks)))
    (brain-update-view)
    (brain-env-info-message (concat (if (brain-env-context-get 'minimize-verbatim-blocks) "minimized" "expanded") " verbatim blocks")))))

(defun brain-toggle-properties-view ()
  "enable or disable the explicit display of atom properties as extra lines within views"
  (interactive)
  (if (brain-env-in-treeview-mode) (progn
    (brain-env-context-set 'view-properties (not (brain-env-context-get 'view-properties)))
    (brain-update-view)
    (brain-env-info-message (concat (if (brain-env-context-get 'view-properties) "enabled" "disabled") " property view")))))

(defun brain-toggle-truncate-lines ()
  "toggle line wrap mode"
  (interactive)
  (if (brain-env-in-treeview-mode) (progn
    (brain-env-context-set 'truncate-long-lines (not (brain-env-context-get 'truncate-long-lines)))
    (brain-update-view))))

(defun brain-update-to-backward-view ()
  "switch to a 'backward' view, i.e. a view in which an atom's parents appear as list items beneath it"
  (interactive)
  (if (brain-env-in-treeview-mode) (progn
      (brain-env-context-set-backward-style)
      (brain-client-refresh-view))))

(defun brain-update-to-forward-view ()
  "switch to a 'forward' view (the default), i.e. a view in which an atom's children appear as list items beneath it"
  (interactive)
  (if (brain-env-in-treeview-mode) (progn
      (brain-env-context-set-forward-style)
      (brain-client-refresh-view))))

(defun brain-update-view ()
  "refresh the current view from the data store"
  (interactive)
  (if (brain-env-in-treeview-mode)
    (brain-client-refresh-view)))

(defun brain-visit-in-amazon (value-selector)
  "search Amazon.com for the value generated by VALUE-SELECTOR and view the results in a browser"
  (visit-focus-value value-selector
    (lambda (value)
      (concat
        "http://www.amazon.com/s?ie=UTF8&index=blended&link_code=qs&field-keywords="
        (brain-client-url-encode value)))))

(defun brain-visit-in-delicious (value-selector)
  "search delicious.com for the value generated by VALUE-SELECTOR and view the results in a browser"
  (visit-focus-value value-selector (lambda (value)
                                       (concat "http://www.delicious.com/search?p=" (brain-client-url-encode value)))))

(defun brain-visit-in-ebay (value-selector)
  "search ebay.com for the value generated by VALUE-SELECTOR and view the results in a browser"
  (visit-focus-value value-selector (lambda (value)
                                       (concat "http://www.ebay.com/sch/i.html?_nkw=" (brain-client-url-encode value)))))

(defun brain-visit-in-google (value-selector)
  "search google.com for the value generated by VALUE-SELECTOR and view the results in a browser"
  (visit-focus-value value-selector (lambda (value)
                                       (concat "http://www.google.com/search?ie=UTF-8&q=" (brain-client-url-encode value)))))

(defun brain-visit-in-google-maps (value-selector)
  "search Google Maps for the value generated by VALUE-SELECTOR and view the results in a browser"
  (visit-focus-value value-selector (lambda (value)
                                       (concat "http://maps.google.com/maps?q=" (brain-client-url-encode value)))))

(defun brain-visit-in-google-scholar (value-selector)
  "search Google Scholar for the value generated by VALUE-SELECTOR and view the results in a browser"
  (visit-focus-value value-selector (lambda (value)
                                       (concat "http://scholar.google.com/scholar?q=" (brain-client-url-encode value)))))

(defun brain-visit-in-twitter (value-selector)
  "search twitter.com for the value generated by VALUE-SELECTOR and view the results in a browser"
  (visit-focus-value value-selector (lambda (value)
                                       (concat "http://twitter.com/#!/search/" (brain-client-url-encode value)))))

(defun brain-visit-in-wikipedia (value-selector)
  "search en.wikipedia.org for the value generated by VALUE-SELECTOR and view the results in a browser"
  (visit-focus-value value-selector (lambda (value)
                                       (concat "http://en.wikipedia.org/w/index.php?title=Special%3ASearch&search=" (brain-client-url-encode value)))))

(defun brain-visit-in-youtube (value-selector)
  "search youtube.com for the value generated by VALUE-SELECTOR and view the results in a browser"
  (visit-focus-value value-selector (lambda (value)
                                       (concat "http://www.youtube.com/results?search_query=" (brain-client-url-encode value)))))

(defun brain-navigate-to-new-atom ()
  "create a new atom and navigate to that atom, opening a new (empty) view with the atom as root"
  (interactive)
  (brain-client-navigate-to-atom "create-new-atom"))

(defun brain-navigate-to-focus-atom ()
  "navigate to the atom at point, opening a new view with that atom as root"
  (interactive)
  (let ((id (brain-data-atom-id-at-point)))
    (if id
      (brain-client-navigate-to-atom id)
      (brain-env-error-no-focus))))

(defun brain-navigate-to-focus-alias ()
  "visit the @alias of the atom at point (normally a URL) in a browser"
  (interactive)
  (let ((alias (brain-data-focus-alias)))
    (if alias
        (browse-url alias)
      (brain-env-error-no-focus))))

(defun brain-visit-as-url (value-selector)
  "visit the URL generated by VALUE-SELECTOR in a browser"
  (interactive)
  (visit-focus-value value-selector (lambda (value) value)))

(defun brain-visit-url-at-point ()
  "visit the URL at point in a browser"
  (interactive)
  (goto-address-at-point))

(defun brain-use-move-submode ()
  (dolist (m brain-move-submode-map)
    (let ((key (car m)) (symbol (cdr m)))
     (mode-define-key key symbol))))

(defun brain-use-edit-submode ()
  (dolist (m brain-move-submode-map)
    (let ((key (car m)) (symbol (cdr m)))
     (mode-define-key key 'nil))))

(defvar brain-move-submode nil)
(defun brain-toggle-move-or-edit-submode ()
  (interactive)
  (if brain-move-submode
    (progn (setq brain-move-submode 'nil)
           (brain-use-edit-submode)
	   (message "submode: edit")
	   (set-cursor-color "#000000")
	   )
    (progn (setq brain-move-submode t)
           (brain-use-move-submode)
	   (message "submode: move")
	   (set-cursor-color "#00ff00")
	   )
    )
  )

(defun brain-insert-attr-priority-prompt ()
  (interactive)
  (prompt-for-char 'brain-insert-attr-priority "priority = ?"))

(defun brain-insert-attr-sharability-prompt ()
  (interactive)
  (prompt-for-char 'brain-insert-attr-sharability "sharability = ?"))

(defun brain-insert-attr-weight-prompt ()
  (interactive)
  (prompt-for-char 'brain-insert-attr-weight "weight = ?"))

(defun brain-set-view-height-prompt ()
  (interactive)
  (prompt-for-char 'brain-set-view-height "height = ?"))

(defun brain-export-vcs-prompt ()
  (interactive)
  (prompt-for-string 'brain-export-vcs "export version-controlled graph to directory: " brain-default-vcs-file))

(defun brain-export-edges-prompt ()
  (interactive)
  (prompt-for-string 'brain-export-edges "export edges to file: " brain-default-edges-file))

(defun brain-export-graphml-prompt ()
  (interactive)
  (prompt-for-string 'brain-export-graphml "export GraphML to file: " brain-default-graphml-file))

(defun brain-export-latex-prompt ()
  (interactive)
  (prompt-for-string 'brain-export-latex "export LaTeX to file: " brain-default-latex-file))

(defun brain-export-pagerank-prompt ()
  (interactive)
  (prompt-for-string 'brain-export-pagerank "export PageRank results to file: " brain-default-pagerank-file))

(defun brain-export-rdf-prompt ()
  (interactive)
  (prompt-for-string 'brain-export-rdf "export N-Triples dump to file: " brain-default-rdf-file))

(defun brain-export-vertices-prompt ()
  (interactive)
  (prompt-for-string 'brain-export-vertices "export vertices to file: " brain-default-vertices-file))

(defun brain-import-vcs-prompt ()
  (interactive)
  (prompt-for-string 'brain-import-vcs "import version-controlled graph from directory: " brain-default-vcs-file))

(defun brain-import-freeplane-prompt ()
  (interactive)
  (prompt-for-string 'brain-import-freeplane "import Freeplane data from file/directory: " brain-default-freeplane-file))

(defun brain-import-graphml-prompt ()
  (interactive)
  (prompt-for-string 'brain-import-graphml "import GraphML from file: " brain-default-graphml-file))

(defun brain-set-min-sharability-prompt ()
  (interactive)
  (prompt-for-char 'brain-set-min-sharability "minimum sharability = ?"))

(defun brain-set-focus-priority-prompt ()
  (interactive)
  (prompt-for-char 'brain-set-focus-priority "new priority = ?"))

(defun brain-set-focus-sharability-prompt ()
  (interactive)
  (prompt-for-char 'brain-set-focus-sharability "new sharability = ?"))

(defun brain-set-focus-weight-prompt ()
  (interactive)
  (prompt-for-char 'brain-set-focus-weight "new weight = ?"))

(defun brain-set-value-truncation-length-prompt ()
  (interactive)
  (prompt-for-string 'brain-set-value-truncation-length "value truncation length: "))

(defun brain-set-min-weight-prompt ()
  (interactive)
  (prompt-for-char 'brain-set-min-weight "minimun weight = ?"))

(defun brain-acronym-query-prompt ()
  (interactive)
  (prompt-for-string 'brain-acronym-query "acronym search for: "))

(defun brain-shortcut-query-prompt ()
  (interactive)
  (prompt-for-string 'brain-shortcut-query "shortcut search for: "))

(defun brain-ripple-query-prompt ()
  (interactive)
  (prompt-for-string 'brain-ripple-query "ripple query: "))

(defun brain-fulltext-query-prompt ()
  (interactive)
  (prompt-for-string 'brain-fulltext-query "full-text search for: "))

(defun brain-push-view-prompt ()
  (interactive)
  (if (eq (read-char "really push view? (press 'z' to confirm)") 122)
      (brain-push-view)
      nil))

(defun brain-update-view-prompt ()
  (interactive)
  (if (eq (read-char "really update view? (press 'm' to confirm)") 109)
      (brain-update-view)
      nil))

(defun visit-focus-value (value-selector value-to-url)
  (lexical-let ((vs value-selector) (vu value-to-url))
    (lambda () (interactive)
      (let ((value (funcall vs)))
        (if value
            (browse-url (funcall vu value))
          (brain-env-error-no-focus))))))

(defun number-shorthand-to-number (c)
  (interactive)
  (let ((l (assoc c fast-numbers)))
    (if l (car (cdr l)) (brain-env-error-message (concat "no number associated with character " (char-to-string c))))))

;; note: works in Aquamacs and MacPorts Emacs, but apparently not in the terminal Emacs 24 on Mac OS X
 (defun copy-to-clipboard (g)
  (let ((buffer (get-buffer-create "*temp*")))
    (with-current-buffer buffer
      (unwind-protect
          (insert g)
        (let ((beg 1) (end (+ (length g) 1)))
          (clipboard-kill-ring-save beg end))
        (kill-buffer buffer)))))

(defun mapkey (c)
  (gethash c line-addr-keymap))

(defun address-to-lineno (address)
  (if (string-match "[0-9asdfghjkl;]+" address)
      (string-to-number (coerce (mapcar 'mapkey (coerce address 'list)) 'string))
    nil))

(defun handle-changewindow (address)
  (let ((c (car (coerce address 'list))))
    (if (string-match "[uiop]" (string c))
        (let ((n (string-to-number (string (gethash c line-addr-keymap)))))
          (other-window n)
          (coerce (cdr (coerce address 'list)) 'string))
      address)))

(defun color-prompt-by-min-sharability (callback)
  (let ((newcol (brain-view-color-at-min-sharability))
        (oldcol (face-foreground 'minibuffer-prompt)))
    (set-face-foreground 'minibuffer-prompt newcol)
    (funcall callback)
    (set-face-foreground 'minibuffer-prompt oldcol)))

(defun prompt-for-string (function prompt &optional initial)
  (color-prompt-by-min-sharability (lambda ()
    ;; note: use of the INITIAL argument is discouraged, but here it makes sense
    (let ((arg (read-from-minibuffer prompt initial)))
      (if arg (funcall function arg))))))

(defun prompt-for-char (function prompt)
  (color-prompt-by-min-sharability (lambda ()
    (let ((c (read-char prompt)))
      (if c (funcall function c))))))

;; "edit"(default) and "move" submodes
    ;; some editing (esp. cut|paste and of properties) is still
    ;; possible in move-mode, but some keys do not print to screen

(if (boundp 'brain-move-submode-map) ()
  (defconst brain-move-submode-map '(
    (";" . brain-toggle-truncate-lines)
    ("b" . brain-update-to-backward-view)
    ("c" . kill-ring-save)
    ("f" . brain-update-to-forward-view)
    ("g" . brain-update-view-prompt)
    ("h" . brain-set-view-height-prompt)
    ("i" . previous-line)  ;; up
    ("I" . scroll-down-command)
    ("j" . backward-char)  ;; left
    ("J" . move-beginning-of-line)
    ("k" . next-line)  ;; down
    ("K" . scroll-up-command)
    ("l" . forward-char)  ;; right
    ("L" . move-end-of-line)
    ("n" . brain-navigate-to-focus-atom-and-kill-buffer)
    ("o" . other-window)
    ("p" . brain-push-view-prompt) ;; shortcut is effectively "p z"
    ("P" . brain-set-priority-and-drop-cursor) ;; !! first use one-liner-view
    ("S" . brain-set-sharability-and-drop-cursor) ;; !! first use one-liner-view
    ("t" . brain-navigate-to-focus-atom)
    ("u" . undo)
    ("v" . yank)
    ("w" . kill-buffer)
    ("W" . brain-set-weight-and-drop-cursor) ;; !! first use one-liner-view
    ("x" . kill-region)
    ("z" . set-mark-command)
)))

(defun brain-set-priority-and-drop-cursor ()
  (interactive)
  (progn (brain-insert-attr-priority-prompt)
        (next-line)))

(defun brain-set-sharability-and-drop-cursor ()
  (interactive)
  (progn (brain-insert-attr-sharability-prompt)
        (next-line)))

(defun brain-set-weight-and-drop-cursor ()
  (interactive)
  (progn (brain-insert-attr-weight-prompt)
        (next-line)))

(defun brain-navigate-to-focus-atom-and-kill-buffer ()
  (interactive)
  (let ((name (buffer-name)))
    (progn (brain-navigate-to-focus-atom)
	   (kill-buffer name))))

(defun my-filter (condp lst)
  ;; https://www.emacswiki.org/emacs/ElispCookbook
  (delq nil
	(mapcar (lambda (x) (and (funcall condp x) x)) lst)))

(defun mode-define-key (key symbol)
   (define-key brain-mode-map (kbd key) symbol))

(defvar brain-mode-map nil)
(if brain-mode-map ()
  (progn
    (setq brain-mode-map (make-sparse-keymap))
    (define-key brain-mode-map (kbd "C-c C-a C-p")     'brain-insert-attr-priority-prompt)
    (define-key brain-mode-map (kbd "C-c C-a C-s")     'brain-insert-attr-sharability-prompt)
    (define-key brain-mode-map (kbd "C-c C-a C-w")     'brain-insert-attr-weight-prompt)
    (define-key brain-mode-map (kbd "C-c C-a d")       'brain-insert-current-date)
    (define-key brain-mode-map (kbd "C-c C-a s")       'brain-insert-current-time-with-seconds)
    (define-key brain-mode-map (kbd "C-c C-a t")       'brain-insert-current-time)
    (define-key brain-mode-map (kbd "C-c C-b")         'brain-visit-url-at-point)
    (define-key brain-mode-map (kbd "C-c C-d")         'brain-set-view-height-prompt)
    (define-key brain-mode-map (kbd "C-c C-f")         'brain-find-roots)
    (define-key brain-mode-map (kbd "C-c C-i f")       'brain-find-isolated-atoms)
    (define-key brain-mode-map (kbd "C-c C-i r")       'brain-remove-isolated-atoms)
    (define-key brain-mode-map (kbd "C-c C-r c")       'brain-import-vcs-prompt)
    (define-key brain-mode-map (kbd "C-c C-r f")       'brain-import-freeplane-prompt)
    (define-key brain-mode-map (kbd "C-c C-r g")       'brain-import-graphml-prompt)
    (define-key brain-mode-map (kbd "C-c C-s C-m")     'brain-set-min-sharability-prompt)
    (define-key brain-mode-map (kbd "C-c C-t C-a b")   'brain-navigate-to-focus-alias)
    (define-key brain-mode-map (kbd "C-c C-t C-b a")   (brain-visit-in-amazon 'brain-data-focus-value))
    (define-key brain-mode-map (kbd "C-c C-t C-b d")   (brain-visit-in-delicious 'brain-data-focus-value))
    (define-key brain-mode-map (kbd "C-c C-t C-b e")   (brain-visit-in-ebay 'brain-data-focus-value))
    (define-key brain-mode-map (kbd "C-c C-t C-b g")   (brain-visit-in-google 'brain-data-focus-value))
    (define-key brain-mode-map (kbd "C-c C-t C-b m")   (brain-visit-in-google-maps 'brain-data-focus-value))
    (define-key brain-mode-map (kbd "C-c C-t C-b s")   (brain-visit-in-google-scholar 'brain-data-focus-value))
    (define-key brain-mode-map (kbd "C-c C-t C-b t")   (brain-visit-in-twitter 'brain-data-focus-value))
    (define-key brain-mode-map (kbd "C-c C-t C-b w")   (brain-visit-in-wikipedia 'brain-data-focus-value))
    (define-key brain-mode-map (kbd "C-c C-t C-b y")   (brain-visit-in-youtube 'brain-data-focus-value))
    (define-key brain-mode-map (kbd "C-c C-t C-p")     'brain-set-focus-priority-prompt)
    (define-key brain-mode-map (kbd "C-c C-t C-s")     'brain-set-focus-sharability-prompt)
    (define-key brain-mode-map (kbd "C-c C-t C-w")     'brain-set-focus-weight-prompt)
    (define-key brain-mode-map (kbd "C-c C-t a")       (brain-visit-as-url 'brain-data-focus-value))
    (define-key brain-mode-map (kbd "C-c C-t i")       (brain-atom-info 'brain-data-focus))
    (define-key brain-mode-map (kbd "C-c C-t l")       'brain-preview-focus-latex-math)
    (define-key brain-mode-map (kbd "C-c C-v ;")       'brain-toggle-truncate-lines)
    (define-key brain-mode-map (kbd "C-c C-v e")       'brain-enter-readwrite-view)
    (define-key brain-mode-map (kbd "C-c C-v i")       'brain-toggle-inference-viewstyle)
    (define-key brain-mode-map (kbd "C-c C-v p")       'brain-toggle-properties-view)
    (define-key brain-mode-map (kbd "C-c C-v r")       'brain-enter-readonly-view)
    (define-key brain-mode-map (kbd "C-c C-v s")       'brain-toggle-emacspeak)
    (define-key brain-mode-map (kbd "C-c C-v t")       'brain-set-value-truncation-length-prompt)
    (define-key brain-mode-map (kbd "C-c C-v v")       'brain-toggle-minimize-verbatim-blocks)
    (define-key brain-mode-map (kbd "C-c C-w C-m")     'brain-set-min-weight-prompt)
    (define-key brain-mode-map (kbd "C-c C-w c")       'brain-export-vcs-prompt)
    (define-key brain-mode-map (kbd "C-c C-w e")       'brain-export-edges-prompt)
    (define-key brain-mode-map (kbd "C-c C-w g")       'brain-export-graphml-prompt)
    (define-key brain-mode-map (kbd "C-c C-w l")       'brain-export-latex-prompt)
    (define-key brain-mode-map (kbd "C-c C-w p")       'brain-export-pagerank-prompt)
    (define-key brain-mode-map (kbd "C-c C-w r")       'brain-export-rdf-prompt)
    (define-key brain-mode-map (kbd "C-c C-w v")       'brain-export-vertices-prompt)
    (define-key brain-mode-map (kbd "C-c P")           'brain-priorities)
    (define-key brain-mode-map (kbd "C-c a")           'brain-acronym-query-prompt)
    (define-key brain-mode-map (kbd "C-c b")           'brain-update-to-backward-view)
    (define-key brain-mode-map (kbd "C-c d")           'brain-duplicates)
    (define-key brain-mode-map (kbd "C-c e")           'brain-events)
    (define-key brain-mode-map (kbd "C-c f")           'brain-update-to-forward-view)
    (define-key brain-mode-map (kbd "C-c h")           'brain-history)
    (define-key brain-mode-map (kbd "C-c i")           'brain-infer-types)
    (define-key brain-mode-map (kbd "C-c m")           'brain-toggle-move-or-edit-submode)
    (define-key brain-mode-map (kbd "C-c n")           'brain-navigate-to-new-atom)
    (define-key brain-mode-map (kbd "C-c o")           'brain-shortcut-query-prompt)
    (define-key brain-mode-map (kbd "C-c p")           'brain-push-view)
    (define-key brain-mode-map (kbd "C-c q")           'brain-ripple-query-prompt)
    (define-key brain-mode-map (kbd "C-c r")           'brain-copy-focus-reference-to-clipboard)
    (define-key brain-mode-map (kbd "C-c s")           'brain-fulltext-query-prompt)
    (define-key brain-mode-map (kbd "C-c t")           'brain-navigate-to-focus-atom)
    (define-key brain-mode-map (kbd "C-c u")           'brain-update-view)
    (define-key brain-mode-map (kbd "C-c v")           'brain-copy-focus-value-to-clipboard)
    (define-key brain-mode-map (kbd "C-c .")           'brain-copy-root-reference-to-clipboard)
    (define-key brain-mode-map (kbd "C-c C-c")         'brain-debug)
    (define-key brain-mode-map (kbd "C-x C-k o")       'brain-kill-other-buffers)
))

;; special mappings reserved for use through emacsclient
;; C-c c  --  brain-data-atom-id-at-point

(provide 'brain-commands)
