;;; menu-bar.el --- define a default menu bar  -*- lexical-binding: t; -*-

;; Copyright (C) 1993-1995, 2000-2025 Free Software Foundation, Inc.

;; Author: Richard M. Stallman
;; Maintainer: emacs-devel@gnu.org
;; Keywords: internal, mouse
;; Package: emacs

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;; Avishai Yacobi suggested some menu rearrangements.

;;; Commentary:

;;; Code:

;; This is referenced by some code below; it is defined in uniquify.el
(defvar uniquify-buffer-name-style)

;; From emulation/cua-base.el; used below
(defvar cua-enable-cua-keys)


;; Don't clobber an existing menu-bar keymap, to preserve any menu-bar key
;; definitions made in loaddefs.el.
(or (lookup-key global-map [menu-bar])
    (define-key global-map [menu-bar] (make-sparse-keymap "menu-bar")))

;; Force Help item to come last, after the major mode's own items.
;; The symbol used to be called `help', but that gets confused with the
;; help key.
(setq menu-bar-final-items '(help-menu))

;; This definition is just to show what this looks like.
;; It gets modified in place when menu-bar-update-buffers is called.
(defvar-keymap global-buffers-menu-map :name "Buffers")

(defvar menu-bar-print-menu
  (let ((menu (make-sparse-keymap "Print")))
    (define-key menu [ps-print-region]
      '(menu-item "PostScript Print Region (B+W)" ps-print-region
                  :enable mark-active
                  :help "Pretty-print marked region in black and white to PostScript printer"))
    (define-key menu [ps-print-buffer]
      '(menu-item "PostScript Print Buffer (B+W)" ps-print-buffer
                  :enable (menu-bar-menu-frame-live-and-visible-p)
                  :help "Pretty-print current buffer in black and white to PostScript printer"))
    (define-key menu [ps-print-region-faces]
      '(menu-item "PostScript Print Region"
                  ps-print-region-with-faces
                  :enable mark-active
                  :help "Pretty-print marked region to PostScript printer"))
    (define-key menu [ps-print-buffer-faces]
      '(menu-item "PostScript Print Buffer"
                  ps-print-buffer-with-faces
                  :enable (menu-bar-menu-frame-live-and-visible-p)
                  :help "Pretty-print current buffer to PostScript printer"))
    (define-key menu [print-region]
      '(menu-item "Print Region" print-region
                  :enable mark-active
                  :help "Print region between mark and current position"))
    (define-key menu [print-buffer]
      '(menu-item "Print Buffer" print-buffer
                  :enable (menu-bar-menu-frame-live-and-visible-p)
                  :help "Print current buffer with page headings"))
    menu))

(defcustom menu-bar-close-window nil
  "Whether or not to close the current window from the menu bar.
If non-nil, selecting Close from the File menu or clicking Close
in the tool bar will close the current window where possible."
  :type 'boolean
  :group 'menu
  :version "30.1")

(defvar menu-bar-file-menu
  (let ((menu (make-sparse-keymap "File")))

    ;; The "File" menu items
    (define-key menu [exit-emacs]
      '(menu-item "Quit" save-buffers-kill-terminal
                  :help "Save unsaved buffers, then exit"))

    (define-key menu [separator-exit]
      menu-bar-separator)

    (define-key menu [print]
      `(menu-item "Print" ,menu-bar-print-menu))

    (define-key menu [separator-print]
      menu-bar-separator)

    (define-key menu [close-tab]
      '(menu-item "Close Tab" tab-close
                  :visible (fboundp 'tab-close)
                  :help "Close currently selected tab"))
    (define-key menu [make-tab]
      '(menu-item "New Tab" tab-new
                  :visible (fboundp 'tab-new)
                  :help "Open a new tab"))

    (define-key menu [separator-tab]
      menu-bar-separator)

    (define-key menu [undelete-frame-mode]
      '(menu-item "Allow Undeleting Frames" undelete-frame-mode
                  :help "Allow frames to be restored after deletion"
                  :button (:toggle . undelete-frame-mode)))

    (define-key menu [undelete-last-deleted-frame]
      '(menu-item "Undelete Frame" undelete-frame
                  :enable (and undelete-frame-mode
                                (car undelete-frame--deleted-frames))
                  :help "Undelete the most recently deleted frame"))

    ;; Don't use delete-frame as event name because that is a special
    ;; event.
    (define-key menu [delete-this-frame]
      '(menu-item "Delete Frame" delete-frame
                  :visible (fboundp 'delete-frame)
                  :enable (delete-frame-enabled-p)
                  :help "Delete currently selected frame"))
    (define-key menu [make-frame-on-monitor]
      '(menu-item "New Frame on Monitor..." make-frame-on-monitor
                  :visible (fboundp 'make-frame-on-monitor)
                  :help "Open a new frame on another monitor"))
    (define-key menu [make-frame-on-display]
      '(menu-item "New Frame on Display Server..." make-frame-on-display
                  :visible (fboundp 'make-frame-on-display)
                  :help "Open a new frame on a display server"))
    (define-key menu [make-frame]
      '(menu-item "New Frame" make-frame-command
                  :visible (fboundp 'make-frame-command)
                  :help "Open a new frame"))

    (define-key menu [separator-frame]
      menu-bar-separator)

    (define-key menu [one-window]
      '(menu-item "Remove Other Windows" delete-other-windows
                  :enable (not (one-window-p t nil))
                  :help "Make selected window fill whole frame"))

    (define-key menu [new-window-on-right]
      '(menu-item "New Window on Right" split-window-right
                  :enable (and (menu-bar-menu-frame-live-and-visible-p)
                               (menu-bar-non-minibuffer-window-p))
                  :help "Make new window on right of selected one"))

    (define-key menu [new-window-below]
      '(menu-item "New Window Below" split-window-below
                  :enable (and (menu-bar-menu-frame-live-and-visible-p)
                               (menu-bar-non-minibuffer-window-p))
                  :help "Make new window below selected one"))

    (define-key menu [separator-window]
      menu-bar-separator)

    (define-key menu [recover-session]
      '(menu-item "Recover Crashed Session" recover-session
                  :enable
                  (and auto-save-list-file-prefix
                       (file-directory-p
                        (file-name-directory auto-save-list-file-prefix))
                       (directory-files
                        (file-name-directory auto-save-list-file-prefix)
                        nil
                        (concat "\\`"
                                (regexp-quote
                                 (file-name-nondirectory
                                  auto-save-list-file-prefix)))
                        t))
                  :help "Recover edits from a crashed session"))
    (define-key menu [revert-buffer]
      '(menu-item
        "Revert Buffer" revert-buffer
        :enable
        (or (not (eq revert-buffer-function
                     'revert-buffer--default))
            (not (eq
                  revert-buffer-insert-file-contents-function
                  'revert-buffer-insert-file-contents--default-function))
            (and buffer-file-number
                 (or (buffer-modified-p)
                     (not (verify-visited-file-modtime
                           (current-buffer)))
                     ;; Enable if the buffer has a different
                     ;; writeability than the file.
                     (not (eq (not buffer-read-only)
                              (file-writable-p buffer-file-name))))))
        :help "Re-read current buffer from its file"))
    (define-key menu [write-file]
      '(menu-item "Save As..." write-file
                  :enable (and (menu-bar-menu-frame-live-and-visible-p)
                               (menu-bar-non-minibuffer-window-p))
                  :help "Write current buffer to another file"))
    (define-key menu [save-buffer]
      '(menu-item "Save" save-buffer
                  :enable (and (buffer-modified-p)
                               (buffer-file-name)
                               (menu-bar-non-minibuffer-window-p))
                  :help "Save current buffer to its file"))

    (define-key menu [separator-save]
      menu-bar-separator)


    (define-key menu [kill-buffer]
      '(menu-item "Close" kill-this-buffer
                  :enable (kill-this-buffer-enabled-p)
                  :help "Discard (kill) current buffer"))
    (define-key menu [insert-file]
      '(menu-item "Insert File..." insert-file
                  :enable (menu-bar-non-minibuffer-window-p)
                  :help "Insert another file into current buffer"))
    (define-key menu [project-dired]
      '(menu-item "Open Project Directory" project-dired
                  :enable (menu-bar-non-minibuffer-window-p)
                  :help "Read the root directory of the current project, to operate on its files"))
    (define-key menu [dired]
      '(menu-item "Open Directory..." dired
                  :enable (menu-bar-non-minibuffer-window-p)
                  :help "Read a directory, to operate on its files"))
    (define-key menu [project-open-file]
      '(menu-item "Open File In Project..." project-find-file
                  :enable (menu-bar-non-minibuffer-window-p)
                  :help "Read existing file that belongs to current project into an Emacs buffer"))
    (define-key menu [open-file]
      '(menu-item "Open File..." menu-find-file-existing
                  :enable (menu-bar-non-minibuffer-window-p)
                  :help "Read an existing file into an Emacs buffer"))
    (define-key menu [new-file]
      '(menu-item "Visit New File..." find-file
                  :enable (menu-bar-non-minibuffer-window-p)
                  :help "Specify a new file's name, to edit the file"))

    menu))

(defun menu-find-file-existing ()
  "Edit the existing file FILENAME."
  (interactive)
  (let* ((mustmatch (not (and (fboundp 'x-uses-old-gtk-dialog)
			      (x-uses-old-gtk-dialog))))
	 (filename (car (find-file-read-args "Find file: " mustmatch))))
    (if mustmatch
	(find-file-existing filename)
      (with-suppressed-warnings ((interactive-only find-file))
        (find-file filename)))))

;; The "Edit->Search" submenu
(defvar menu-bar-last-search-type nil
  "Type of last non-incremental search command called from the menu.")

(defun nonincremental-repeat-search-forward ()
  "Search forward for the previous search string or regexp."
  (interactive)
  (cond
   ((and (eq menu-bar-last-search-type 'string)
	 search-ring)
    (nonincremental-search-forward))
   ((and (eq menu-bar-last-search-type 'regexp)
	 regexp-search-ring)
    (re-search-forward (car regexp-search-ring)))
   (t
    (error "No previous search"))))

(defun nonincremental-repeat-search-backward ()
  "Search backward for the previous search string or regexp."
  (interactive)
  (cond
   ((and (eq menu-bar-last-search-type 'string)
	 search-ring)
    (nonincremental-search-backward))
   ((and (eq menu-bar-last-search-type 'regexp)
	 regexp-search-ring)
    (re-search-backward (car regexp-search-ring)))
   (t
    (error "No previous search"))))

(defun nonincremental-search-forward (&optional string backward)
  "Read a string and search for it nonincrementally."
  (interactive "sSearch for string: ")
  (setq menu-bar-last-search-type 'string)
  ;; Ideally, this whole command would be equivalent to `C-s RET'.
  (let ((isearch-forward (not backward))
        (isearch-regexp-function search-default-mode)
        (isearch-regexp nil))
    (if (or (equal string "") (not string))
        (funcall (isearch-search-fun-default) (car search-ring))
      (isearch-update-ring string nil)
      (funcall (isearch-search-fun-default) string))))

(defun nonincremental-search-backward (&optional string)
  "Read a string and search backward for it nonincrementally."
  (interactive "sSearch backwards for string: ")
  (nonincremental-search-forward string 'backward))

(defun nonincremental-re-search-forward (string)
  "Read a regular expression and search for it nonincrementally."
  (interactive "sSearch for regexp: ")
  (setq menu-bar-last-search-type 'regexp)
  (if (equal string "")
      (re-search-forward (car regexp-search-ring))
    (isearch-update-ring string t)
    (re-search-forward string)))

(defun nonincremental-re-search-backward (string)
  "Read a regular expression and search backward for it nonincrementally."
  (interactive "sSearch for regexp: ")
  (setq menu-bar-last-search-type 'regexp)
  (if (equal string "")
      (re-search-backward (car regexp-search-ring))
    (isearch-update-ring string t)
    (re-search-backward string)))

;; The Edit->Incremental Search menu
(defvar menu-bar-i-search-menu
  (let ((menu (make-sparse-keymap "Incremental Search")))
    (define-key menu [isearch-forward-symbol-at-point]
      '(menu-item "Forward Symbol at Point..." isearch-forward-symbol-at-point
        :help "Search forward for a symbol found at point"))
    (define-key menu [isearch-forward-symbol]
      '(menu-item "Forward Symbol..." isearch-forward-symbol
        :help "Search forward for a symbol as you type it"))
    (define-key menu [isearch-forward-word]
      '(menu-item "Forward Word..." isearch-forward-word
        :help "Search forward for a word as you type it"))
    (define-key menu [isearch-backward-regexp]
      '(menu-item "Backward Regexp..." isearch-backward-regexp
        :help "Search backwards for a regular expression as you type it"))
    (define-key menu [isearch-forward-regexp]
      '(menu-item "Forward Regexp..." isearch-forward-regexp
        :help "Search forward for a regular expression as you type it"))
    (define-key menu [isearch-backward]
      '(menu-item "Backward String..." isearch-backward
        :help "Search backwards for a string as you type it"))
    (define-key menu [isearch-forward]
      '(menu-item "Forward String..." isearch-forward
        :help "Search forward for a string as you type it"))
    menu))

(defvar menu-bar-search-menu
  (let ((menu (make-sparse-keymap "Search")))
    (define-key menu [tags-continue]
      '(menu-item "Continue Tags Search" fileloop-continue
                  :enable (and (featurep 'fileloop)
                               (not (eq fileloop--operate-function 'ignore)))
                  :help "Continue last tags search operation"))
    (define-key menu [tags-srch]
      '(menu-item "Search Tagged Files..." tags-search
                  :help "Search for a regexp in all tagged files"))
    (define-key menu [project-search]
      '(menu-item "Search in Project Files..." project-find-regexp
        :help "Search for a regexp in files belonging to current project"))
    (define-key menu [separator-tag-search] menu-bar-separator)

    (define-key menu [repeat-search-back]
      '(menu-item "Repeat Backwards"
                  nonincremental-repeat-search-backward
                  :enable (or (and (eq menu-bar-last-search-type 'string)
                                   search-ring)
                              (and (eq menu-bar-last-search-type 'regexp)
                                   regexp-search-ring))
                  :help "Repeat last search backwards"))
    (define-key menu [repeat-search-fwd]
      '(menu-item "Repeat Forward"
                  nonincremental-repeat-search-forward
                  :enable (or (and (eq menu-bar-last-search-type 'string)
                                   search-ring)
                              (and (eq menu-bar-last-search-type 'regexp)
                                   regexp-search-ring))
                  :help "Repeat last search forward"))
    (define-key menu [separator-repeat-search]
      menu-bar-separator)

    (define-key menu [re-search-backward]
      '(menu-item "Regexp Backwards..."
                  nonincremental-re-search-backward
                  :help "Search backwards for a regular expression"))
    (define-key menu [re-search-forward]
      '(menu-item "Regexp Forward..."
                  nonincremental-re-search-forward
                  :help "Search forward for a regular expression"))

    (define-key menu [search-backward]
      '(menu-item "String Backwards..."
                  nonincremental-search-backward
                  :help "Search backwards for a string"))
    (define-key menu [search-forward]
      '(menu-item "String Forward..." nonincremental-search-forward
                  :help "Search forward for a string"))
    menu))

;; The Edit->Replace submenu

(defvar menu-bar-replace-menu
  (let ((menu (make-sparse-keymap "Replace")))
    (define-key menu [tags-repl-continue]
      '(menu-item "Continue Replace" fileloop-continue
                  :enable (and (featurep 'fileloop)
                               (not (eq fileloop--operate-function 'ignore)))
                  :help "Continue last tags replace operation"))
    (define-key menu [tags-repl]
      '(menu-item "Replace in Tagged Files..." tags-query-replace
        :help "Interactively replace a regexp in all tagged files"))
    (define-key menu [project-replace]
      '(menu-item "Replace in Project Files..." project-query-replace-regexp
        :help "Interactively replace a regexp in files belonging to current project"))
    (define-key menu [separator-replace-tags]
      menu-bar-separator)

    (define-key menu [query-replace-regexp]
      '(menu-item "Replace Regexp..." query-replace-regexp
                  :enable (not buffer-read-only)
                  :help "Replace regular expression interactively, ask about each occurrence"))
    (define-key menu [query-replace]
      '(menu-item "Replace String..." query-replace
        :enable (not buffer-read-only)
        :help "Replace string interactively, ask about each occurrence"))
    menu))

;;; Assemble the top-level Edit menu items.
(defvar menu-bar-goto-menu
  (let ((menu (make-sparse-keymap "Go To")))

    (define-key menu [set-tags-name]
      '(menu-item "Set Tags File Name..." visit-tags-table
                  :visible (menu-bar-goto-uses-etags-p)
                  :help "Tell navigation commands which tag table file to use"))

    (define-key menu [separator-tag-file]
      '(menu-item "--" nil :visible (menu-bar-goto-uses-etags-p)))

    (define-key menu [xref-forward]
      '(menu-item "Forward" xref-go-forward
                  :visible (and (featurep 'xref)
                                (not (xref-forward-history-empty-p)))
                  :help "Forward to the position gone Back from"))

    (define-key menu [xref-pop]
      '(menu-item "Back" xref-go-back
                  :visible (and (featurep 'xref)
                                (not (xref-marker-stack-empty-p)))
                  :help "Back to the position of the last search"))

    (define-key menu [xref-apropos]
      '(menu-item "Find Apropos..." xref-find-apropos
                  :help "Find function/variables whose names match regexp"))

    (define-key menu [xref-find-otherw]
      '(menu-item "Find Definition in Other Window..."
                  xref-find-definitions-other-window
                  :help "Find function/variable definition in another window"))
    (define-key menu [xref-find-def]
      '(menu-item "Find Definition..." xref-find-definitions
                  :help "Find definition of function or variable"))

    (define-key menu [separator-xref]
      menu-bar-separator)

    (define-key menu [end-of-buf]
      '(menu-item "Goto End of Buffer" end-of-buffer))
    (define-key menu [beg-of-buf]
      '(menu-item "Goto Beginning of Buffer" beginning-of-buffer))
    (define-key menu [go-to-pos]
      '(menu-item "Goto Buffer Position..." goto-char
                  :help "Read a number N and go to buffer position N"))
    (define-key menu [go-to-line]
      '(menu-item "Goto Line..." goto-line
                  :help "Read a line number and go to that line"))
    menu))

(defun menu-bar-goto-uses-etags-p ()
  (or (not (boundp 'xref-backend-functions))
      (eq (car xref-backend-functions) 'etags--xref-backend)))

(defvar yank-menu '("Select Yank" nil))
(fset 'yank-menu (cons 'keymap yank-menu))

(defvar menu-bar-edit-menu
  (let ((menu (make-sparse-keymap "Edit")))

    (define-key menu [execute-extended-command]
      '(menu-item "Execute Command" execute-extended-command
                  :enable t
                  :help "Read a command name, its arguments, then call it."))

    ;; ns-win.el said: Add spell for platform consistency.
    (if (featurep 'ns)
        (define-key menu [spell]
          '(menu-item "Spell" ispell-menu-map)))

    (define-key menu [fill]
      '(menu-item "Fill" fill-region
                  :enable (and mark-active (not buffer-read-only))
                  :help
                  "Fill text in region to fit between left and right margin"))

    (define-key menu [separator-bookmark]
      menu-bar-separator)

    (define-key menu [bookmark]
      '(menu-item "Bookmarks" menu-bar-bookmark-map))

    (define-key menu [goto]
      `(menu-item "Go To" ,menu-bar-goto-menu))

    (define-key menu [replace]
      `(menu-item "Replace" ,menu-bar-replace-menu))

    (define-key menu [i-search]
      `(menu-item "Incremental Search" ,menu-bar-i-search-menu))

    (define-key menu [search]
      `(menu-item "Search" ,menu-bar-search-menu))

    (define-key menu [separator-search]
      menu-bar-separator)

    (define-key menu [mark-whole-buffer]
      '(menu-item "Select All" mark-whole-buffer
                  :help "Mark the whole buffer for a subsequent cut/copy"))
    (define-key menu [clear]
      '(menu-item "Clear" delete-active-region
                  :enable (and mark-active
                               (not buffer-read-only))
                  :help
                  "Delete the text in region between mark and current position"))


    (define-key menu (if (featurep 'ns) [select-paste]
                       [paste-from-menu])
      ;; ns-win.el said: Change text to be more consistent with
      ;; surrounding menu items `paste', etc."
      `(menu-item ,(if (featurep 'ns) "Select and Paste" "Paste from Kill Menu")
                  yank-menu
                  :enable (and (cdr yank-menu) (not buffer-read-only))
                  :help "Choose a string from the kill ring and paste it"))
    (define-key menu [paste]
      `(menu-item "Paste" yank
                  :enable (funcall
                           ',(lambda ()
                               (and (not buffer-read-only)
                                    (or
                                     (gui-backend-selection-exists-p 'CLIPBOARD)
                                     (if (featurep 'ns) ; like paste-from-menu
                                         (cdr yank-menu)
                                       kill-ring)))))
                  :help "Paste (yank) text most recently cut/copied"
                  :keys ,(lambda ()
                           (if cua-mode
                               "\\[cua-paste]"
                             "\\[yank]"))))
    (define-key menu [copy]
      ;; ns-win.el said: Substitute a Copy function that works better
      ;; under X (for GNUstep).
      `(menu-item "Copy" ,(if (featurep 'ns)
                              'ns-copy-including-secondary
                            'kill-ring-save)
                  :enable mark-active
                  :help "Copy text in region between mark and current position"
                  :keys ,(lambda ()
                           (cond
                            ((featurep 'ns)
                             "\\[ns-copy-including-secondary]")
                            ((and cua-mode mark-active)
                             "\\[cua-copy-handler]")
                            (t
                             "\\[kill-ring-save]")))))
    (define-key menu [cut]
      `(menu-item "Cut" kill-region
                  :enable (and mark-active (not buffer-read-only))
                  :help
                  "Cut (kill) text in region between mark and current position"
                  :keys ,(lambda ()
                           (if (and cua-mode mark-active)
                               "\\[cua-cut-handler]"
                             "\\[kill-region]"))))
    ;; ns-win.el said: Separate undo from cut/paste section.
    (if (featurep 'ns)
        (define-key menu [separator-undo] menu-bar-separator))

    (define-key menu [undo-redo]
      '(menu-item "Redo" undo-redo
                  :enable (and (not buffer-read-only)
                           (undo--last-change-was-undo-p buffer-undo-list))
                  :help "Redo last undone edits"))

    (define-key menu [undo]
      '(menu-item "Undo" undo
                  :enable (and (not buffer-read-only)
                               (not (eq t buffer-undo-list))
                               (if (eq last-command 'undo)
                                   (listp pending-undo-list)
                                 (consp buffer-undo-list)))
                  :help "Undo last edits"))

    menu))

;; These are alternative definitions for the cut, paste and copy
;; menu items.  Use them if your system expects these to use the clipboard.

(put 'clipboard-kill-region 'menu-enable
     '(and mark-active (not buffer-read-only)))
(put 'clipboard-kill-ring-save 'menu-enable 'mark-active)
(put 'clipboard-yank 'menu-enable
     `(funcall ',(lambda ()
                   (and (or (gui-backend-selection-exists-p 'PRIMARY)
                            (gui-backend-selection-exists-p 'CLIPBOARD))
                        (not buffer-read-only)))))

(defun clipboard-yank ()
  "Insert the clipboard contents, or the last stretch of killed text."
  (interactive "*")
  (let ((select-enable-clipboard t)
        ;; Ensure that we defeat the DWIM logic in `gui-selection-value'
        ;; (i.e., that gui--clipboard-selection-unchanged-p returns nil).
        (gui--last-selected-text-clipboard nil))
    (yank)))

(defun clipboard-kill-ring-save (beg end &optional region)
  "Copy region to kill ring, and save in the GUI's clipboard.
If the optional argument REGION is non-nil, the function ignores
BEG and END, and saves the current region instead."
  (interactive "r\np")
  (let ((select-enable-clipboard t))
    (kill-ring-save beg end region)))

(defun clipboard-kill-region (beg end &optional region)
  "Kill the region, and save it in the GUI's clipboard.
If the optional argument REGION is non-nil, the function ignores
BEG and END, and kills the current region instead."
  (interactive "r\np")
  (let ((select-enable-clipboard t))
    (kill-region beg end region)))

(defun menu-bar-enable-clipboard ()
  "Make CUT, PASTE and COPY (keys and menu bar items) use the clipboard.
Do the same for the keys of the same name."
  (interactive)
  ;; These are Sun server keysyms for the Cut, Copy and Paste keys
  ;; (also for XFree86 on Sun keyboard):
  (define-key global-map [f20] 'clipboard-kill-region)
  (define-key global-map [f16] 'clipboard-kill-ring-save)
  (define-key global-map [f18] 'clipboard-yank)
  ;; X11 versions:
  (define-key global-map [cut] 'clipboard-kill-region)
  (define-key global-map [copy] 'clipboard-kill-ring-save)
  (define-key global-map [paste] 'clipboard-yank))

;; The "Options" menu items

(defvar menu-bar-custom-menu
  (let ((menu (make-sparse-keymap "Customize")))

    (define-key menu [customize-apropos-faces]
      '(menu-item "Faces Matching..." customize-apropos-faces
                  :help "Browse faces matching a regexp or word list"))
    (define-key menu [customize-apropos-options]
      '(menu-item "Options Matching..." customize-apropos-options
                  :help "Browse options matching a regexp or word list"))
    (define-key menu [customize-apropos]
      '(menu-item "All Settings Matching..." customize-apropos
                  :help "Browse customizable settings matching a regexp or word list"))
    (define-key menu [separator-1]
      menu-bar-separator)
    (define-key menu [customize-group]
      '(menu-item "Specific Group..." customize-group
                  :help "Customize settings of specific group"))
    (define-key menu [customize-face]
      '(menu-item "Specific Face..." customize-face
                  :help "Customize attributes of specific face"))
    (define-key menu [customize-option]
      '(menu-item "Specific Option..." customize-option
                  :help "Customize value of specific option"))
    (define-key menu [separator-2]
      menu-bar-separator)
    (define-key menu [customize-changed]
      '(menu-item "New Options..." customize-changed
                  :help "Options and faces added or changed in recent Emacs versions"))
    (define-key menu [customize-saved]
      '(menu-item "Saved Options" customize-saved
                  :help "Customize previously saved options"))
    (define-key menu [separator-3]
      menu-bar-separator)
    (define-key menu [customize-browse]
      '(menu-item "Browse Customization Groups" customize-browse
                  :help "Tree-like browser of all the groups of customizable options"))
    (define-key menu [customize]
      '(menu-item "Top-level Emacs Customization Group" customize
                  :help "Top-level groups of customizable options, and their descriptions"))
    (define-key menu [customize-themes]
      '(menu-item "Custom Themes" customize-themes
                  :help "Choose a pre-defined customization theme"))
    menu))
;(defvar-keymap menu-bar-preferences-menu :name "Preferences")

(defmacro menu-bar-make-mm-toggle (fname doc help &optional props)
  "Make a menu-item for a global minor mode toggle.
FNAME is the minor mode's name (variable and function).
DOC is the text to use for the menu entry.
HELP is the text to use for the tooltip.
PROPS are additional properties."
  `'(menu-item ,doc ,fname
	       ,@props
	       :help ,help
	       :button (:toggle . (and (default-boundp ',fname)
				       (default-value ',fname)))))

(defmacro menu-bar-make-toggle (command variable item-name message help
                                        &rest body)
  "Define a menu-bar toggle command.
See `menu-bar-make-toggle-command', for which this is a
compatibility wrapper.  BODY is passed in as SETTING-SEXP in that macro."
  (declare (obsolete menu-bar-make-toggle-command "28.1"))
  `(menu-bar-make-toggle-command ,command ,variable ,item-name ,message ,help
                                 ,(and body
                                       `(progn
                                          ,@body))))

(defmacro menu-bar-make-toggle-command (command variable item-name message
                                                help
                                                &optional setting-sexp
                                                &rest keywords)
  "Define a menu-bar toggle command.
COMMAND (a symbol) is the toggle command to define.

VARIABLE (a symbol) is the variable to set.

ITEM-NAME (a string) is the menu-item name.

MESSAGE is a format string for the toggle message, with %s for the new
status.

HELP (a string) is the `:help' tooltip text and the doc string first
line (minus final period) for the command.

SETTING-SEXP is a Lisp sexp that sets VARIABLE, or it is nil meaning
set it according to its `defcustom' or using `set-default'.

KEYWORDS is a plist for `menu-item' for keywords other than `:help'."
  `(progn
     (defun ,command (&optional interactively)
       ,(concat "Toggle whether to " (downcase (substring help 0 1))
                (substring help 1) ".
In an interactive call, record this option as a candidate for saving
by \"Save Options\" in Custom buffers.")
       (interactive "p")
       (if ,(if setting-sexp
                `,setting-sexp
              `(progn
		 (custom-load-symbol ',variable)
		 (let ((set (or (get ',variable 'custom-set) 'set-default))
		       (get (or (get ',variable 'custom-get) 'default-value)))
		   (funcall set ',variable (not (funcall get ',variable))))))
           (message ,message "enabled globally")
         (message ,message "disabled globally"))
       ;; `customize-mark-as-set' must only be called when a variable is set
       ;; interactively, because the purpose is to mark the variable as a
       ;; candidate for `Save Options', and we do not want to save options that
       ;; the user has already set explicitly in the init file.
       (when interactively
         (customize-mark-as-set ',variable))
       ;; Toggle menu items must make sure that the menu is updated so
       ;; that toggle marks are drawn in the right state.
       (force-mode-line-update t))
     '(menu-item ,item-name ,command :help ,help
                 :button (:toggle . (and (default-boundp ',variable)
                                         (default-value ',variable)))
                 ,@keywords)))

;; Function for setting/saving default font.

(defun menu-set-font ()
  "Interactively select a font and make it the default on all frames.

The selected font will be the default on both the existing and future frames."
  (interactive)
  (set-frame-font (if (fboundp 'x-select-font)
		      (x-select-font)
		    (mouse-select-font))
		  nil t))

(defun menu-bar-options-save ()
  "Save current values of Options menu items using Custom."
  (interactive)
  (let ((need-save nil))
    ;; These are set with menu-bar-make-mm-toggle, which does not
    ;; put on a customized-value property.
    (dolist (elt '(global-display-line-numbers-mode display-line-numbers-type
		   line-number-mode column-number-mode size-indication-mode
		   cua-mode show-paren-mode transient-mark-mode
		   blink-cursor-mode display-time-mode display-battery-mode
		   ;; These are set by other functions that don't set
		   ;; the customized state.  Having them here has the
		   ;; side-effect that turning them off via X
		   ;; resources acts like having customized them, but
		   ;; that seems harmless.
		   menu-bar-mode tab-bar-mode tool-bar-mode))
      ;; FIXME ? It's a little annoying that running this command
      ;; always loads cua-base, paren, time, and battery, even if they
      ;; have not been customized in any way.  (Due to custom-load-symbol.)
      (and (customize-mark-to-save elt)
	   (setq need-save t)))
    ;; These are set with `customize-set-variable'.
    (dolist (elt '(scroll-bar-mode
		   debug-on-quit debug-on-error
		   ;; Somehow this works, when tool-bar and menu-bar don't.
                   desktop-save-mode
		   tooltip-mode window-divider-mode
		   save-place-mode uniquify-buffer-name-style fringe-mode
		   indicate-empty-lines indicate-buffer-boundaries
		   case-fold-search font-use-system-font
		   current-language-environment default-input-method
		   ;; Saving `text-mode-hook' is somewhat questionable,
		   ;; as we might get more than we bargain for, if
		   ;; other code may has added hooks as well.
		   ;; Nonetheless, not saving it would like be confuse
		   ;; more often.
		   ;; -- Per Abrahamsen <abraham@dina.kvl.dk> 2002-02-11.
		   text-mode-hook tool-bar-position))
      (and (get elt 'customized-value)
	   (customize-mark-to-save elt)
	   (setq need-save t)))
    (when (get 'default 'customized-face)
      (put 'default 'saved-face (get 'default 'customized-face))
      (put 'default 'customized-face nil)
      (setq need-save t))
    ;; Save if we changed anything.
    (when need-save
      (custom-save-all))))


;;; Assemble all the top-level items of the "Options" menu

;; The "Show/Hide" submenu of menu "Options"

(defun menu-bar-window-divider-customize ()
  "Show customization buffer for `window-divider' group."
  (interactive)
  (customize-group 'window-divider))

(defun menu-bar-bottom-and-right-window-divider ()
  "Display dividers on the bottom and right of each window."
  (interactive)
  (customize-set-variable 'window-divider-default-places t)
  (window-divider-mode 1))

(defun menu-bar-right-window-divider ()
  "Display dividers only on the right of each window."
  (interactive)
  (customize-set-variable 'window-divider-default-places 'right-only)
  (window-divider-mode 1))

(defun menu-bar-bottom-window-divider ()
  "Display dividers only at the bottom of each window."
  (interactive)
  (customize-set-variable 'window-divider-default-places 'bottom-only)
  (window-divider-mode 1))

(defun menu-bar-no-window-divider ()
  "Do not display window dividers."
  (interactive)
  (window-divider-mode -1))

;; For the radio buttons below we check whether the respective dividers
;; are displayed on the selected frame.  This is not fully congruent
;; with `window-divider-mode' but makes the menu entries work also when
;; dividers are displayed by manipulating frame parameters directly.
(defvar menu-bar-showhide-window-divider-menu
  (let ((menu (make-sparse-keymap "Window Divider")))
    (define-key menu [customize]
      '(menu-item "Customize" menu-bar-window-divider-customize
                  :help "Customize window dividers"
                  :visible (memq (window-system) '(x w32))))

    (define-key menu [bottom-and-right]
      '(menu-item "Bottom and Right"
                  menu-bar-bottom-and-right-window-divider
                  :help "Display window divider on the bottom and right of each window"
                  :visible (memq (window-system) '(x w32))
                  :button (:radio
			   . (and (window-divider-width-valid-p
				   (cdr (assq 'bottom-divider-width
					      (frame-parameters))))
				  (window-divider-width-valid-p
				   (cdr (assq 'right-divider-width
					      (frame-parameters))))))))
    (define-key menu [right-only]
      '(menu-item "Right Only"
                  menu-bar-right-window-divider
                  :help "Display window divider on the right of each window only"
                  :visible (memq (window-system) '(x w32))
                  :button (:radio
			   . (and (not (window-divider-width-valid-p
					(cdr (assq 'bottom-divider-width
						   (frame-parameters)))))
				  (window-divider-width-valid-p
				   (cdr (assq 'right-divider-width
						     (frame-parameters))))))))
    (define-key menu [bottom-only]
      '(menu-item "Bottom Only"
                  menu-bar-bottom-window-divider
                  :help "Display window divider on the bottom of each window only"
                  :visible (memq (window-system) '(x w32))
                  :button (:radio
			   . (and (window-divider-width-valid-p
				   (cdr (assq 'bottom-divider-width
					      (frame-parameters))))
				  (not (window-divider-width-valid-p
					(cdr (assq 'right-divider-width
						   (frame-parameters)))))))))
    (define-key menu [no-divider]
      '(menu-item "None"
                  menu-bar-no-window-divider
                  :help "Do not display window dividers"
                  :visible (memq (window-system) '(x w32))
                  :button (:radio
			   . (and (not (window-divider-width-valid-p
					(cdr (assq 'bottom-divider-width
						   (frame-parameters)))))
				  (not (window-divider-width-valid-p
					(cdr (assq 'right-divider-width
						   (frame-parameters)))))))))
    menu))

(defun menu-bar-showhide-fringe-ind-customize ()
  "Show customization buffer for `indicate-buffer-boundaries'."
  (interactive)
  (customize-variable 'indicate-buffer-boundaries))

(defun menu-bar-showhide-fringe-ind-mixed ()
  "Display top and bottom indicators in opposite fringes, arrows in right."
  (interactive)
  (customize-set-variable 'indicate-buffer-boundaries
			  '((t . right) (top . left))))

(defun menu-bar-showhide-fringe-ind-box ()
  "Display top and bottom indicators in opposite fringes."
  (interactive)
  (customize-set-variable 'indicate-buffer-boundaries
			  '((top . left) (bottom . right))))

(defun menu-bar-showhide-fringe-ind-right ()
  "Display buffer boundaries and arrows in the right fringe."
  (interactive)
  (customize-set-variable 'indicate-buffer-boundaries 'right))

(defun menu-bar-showhide-fringe-ind-left ()
  "Display buffer boundaries and arrows in the left fringe."
  (interactive)
  (customize-set-variable 'indicate-buffer-boundaries 'left))

(defun menu-bar-showhide-fringe-ind-none ()
  "Do not display any buffer boundary indicators."
  (interactive)
  (customize-set-variable 'indicate-buffer-boundaries nil))

(defvar menu-bar-showhide-fringe-ind-menu
  (let ((menu (make-sparse-keymap "Buffer boundaries")))

    (define-key menu [customize]
      '(menu-item "Other (Customize)"
                  menu-bar-showhide-fringe-ind-customize
                  :help "Additional choices available through Custom buffer"
                  :visible (display-graphic-p)
                  :button (:radio . (not (member indicate-buffer-boundaries
                                                 '(nil left right
                                                   ((top . left) (bottom . right))
                                                   ((t . right) (top . left))))))))

    (define-key menu [mixed]
      '(menu-item "Opposite, Arrows Right" menu-bar-showhide-fringe-ind-mixed
                  :help
                  "Show top/bottom indicators in opposite fringes, arrows in right"
                  :visible (display-graphic-p)
                  :button (:radio . (equal indicate-buffer-boundaries
                                           '((t . right) (top . left))))))

    (define-key menu [box]
      '(menu-item "Opposite, No Arrows" menu-bar-showhide-fringe-ind-box
                  :help "Show top/bottom indicators in opposite fringes, no arrows"
                  :visible (display-graphic-p)
                  :button (:radio . (equal indicate-buffer-boundaries
                                           '((top . left) (bottom . right))))))

    (define-key menu [right]
      '(menu-item "In Right Fringe" menu-bar-showhide-fringe-ind-right
                  :help "Show buffer boundaries and arrows in right fringe"
                  :visible (display-graphic-p)
                  :button (:radio . (eq indicate-buffer-boundaries 'right))))

    (define-key menu [left]
      '(menu-item "In Left Fringe" menu-bar-showhide-fringe-ind-left
                  :help "Show buffer boundaries and arrows in left fringe"
                  :visible (display-graphic-p)
                  :button (:radio . (eq indicate-buffer-boundaries 'left))))

    (define-key menu [none]
      '(menu-item "No Indicators" menu-bar-showhide-fringe-ind-none
                  :help "Hide all buffer boundary indicators and arrows"
                  :visible (display-graphic-p)
                  :button (:radio . (eq indicate-buffer-boundaries nil))))
    menu))

(defun menu-bar-showhide-fringe-menu-customize ()
  "Show customization buffer for `fringe-mode'."
  (interactive)
  (customize-variable 'fringe-mode))

(defun menu-bar-showhide-fringe-menu-customize-reset ()
  "Reset the fringe mode: display fringes on both sides of a window."
  (interactive)
  (customize-set-variable 'fringe-mode nil))

(defun menu-bar-showhide-fringe-menu-customize-right ()
  "Display fringes only on the right of each window."
  (interactive)
  (require 'fringe)
  (customize-set-variable 'fringe-mode '(0 . nil)))

(defun menu-bar-showhide-fringe-menu-customize-left ()
  "Display fringes only on the left of each window."
  (interactive)
  (require 'fringe)
  (customize-set-variable 'fringe-mode '(nil . 0)))

(defun menu-bar-showhide-fringe-menu-customize-disable ()
  "Do not display window fringes."
  (interactive)
  (require 'fringe)
  (customize-set-variable 'fringe-mode 0))

(defvar menu-bar-showhide-fringe-menu
  (let ((menu (make-sparse-keymap "Fringe")))

    (define-key menu [showhide-fringe-ind]
      `(menu-item "Buffer Boundaries" ,menu-bar-showhide-fringe-ind-menu
                  :visible (display-graphic-p)
                  :help "Indicate buffer boundaries in fringe"))

    (define-key menu [indicate-empty-lines]
      (menu-bar-make-toggle-command
       toggle-indicate-empty-lines indicate-empty-lines
       "Empty Line Indicators"
       "Indicating of empty lines %s"
       "Indicate trailing empty lines in fringe, globally"))

    (define-key menu [customize]
      '(menu-item "Customize Fringe" menu-bar-showhide-fringe-menu-customize
                  :help "Detailed customization of fringe"
                  :visible (display-graphic-p)))

    (define-key menu [default]
      '(menu-item "Default" menu-bar-showhide-fringe-menu-customize-reset
                  :help "Default width fringe on both left and right side"
                  :visible (display-graphic-p)
                  :button (:radio . (eq fringe-mode nil))))

    (define-key menu [right]
      '(menu-item "On the Right" menu-bar-showhide-fringe-menu-customize-right
                  :help "Fringe only on the right side"
                  :visible (display-graphic-p)
                  :button (:radio . (equal fringe-mode '(0 . nil)))))

    (define-key menu [left]
      '(menu-item "On the Left" menu-bar-showhide-fringe-menu-customize-left
                  :help "Fringe only on the left side"
                  :visible (display-graphic-p)
                  :button (:radio . (equal fringe-mode '(nil . 0)))))

    (define-key menu [none]
      '(menu-item "None" menu-bar-showhide-fringe-menu-customize-disable
                  :help "Turn off fringe"
                  :visible (display-graphic-p)
                  :button (:radio . (eq fringe-mode 0))))
    menu))

(defun menu-bar-right-scroll-bar ()
  "Display scroll bars on the right of each window."
  (interactive)
  (customize-set-variable 'scroll-bar-mode 'right))

(defun menu-bar-left-scroll-bar ()
  "Display scroll bars on the left of each window."
  (interactive)
  (customize-set-variable 'scroll-bar-mode 'left))

(defun menu-bar-no-scroll-bar ()
  "Turn off scroll bars."
  (interactive)
  (customize-set-variable 'scroll-bar-mode nil))

(defvar menu-bar-showhide-scroll-bar-menu
  (let ((menu (make-sparse-keymap "Scroll Bar")))

    (define-key menu [horizontal]
      (menu-bar-make-mm-toggle horizontal-scroll-bar-mode
                               "Horizontal"
                               "Horizontal scroll bar"))

    (define-key menu [scrollbar-separator]
      menu-bar-separator)

    (define-key menu [right]
      '(menu-item "On the Right" menu-bar-right-scroll-bar
                  :help "Scroll bar on the right side"
                  :visible (display-graphic-p)
                  :button (:radio . (and scroll-bar-mode
                                         (eq (frame-parameter
                                              nil 'vertical-scroll-bars)
                                             'right)))))

    (define-key menu [left]
      '(menu-item "On the Left" menu-bar-left-scroll-bar
                  :help "Scroll bar on the left side"
                  :visible (display-graphic-p)
                  :button (:radio . (and scroll-bar-mode
                                         (eq (frame-parameter
                                              nil 'vertical-scroll-bars)
                                             'left)))))

    (define-key menu [none]
      '(menu-item "No Vertical Scroll Bar" menu-bar-no-scroll-bar
                  :help "Turn off vertical scroll bar"
                  :visible (display-graphic-p)
                  :button (:radio . (eq scroll-bar-mode nil))))
    menu))

(defun menu-bar-frame-for-menubar ()
  "Return the frame suitable for updating the menu bar."
  (or (and (framep menu-updating-frame)
	   menu-updating-frame)
      (selected-frame)))

(defun menu-bar-positive-p (val)
  "Return non-nil if VAL is a positive number."
  (and (numberp val)
       (> val 0)))

(defun menu-bar-set-tool-bar-position (position)
  (customize-set-variable 'tool-bar-mode t)
  (customize-set-variable 'tool-bar-position position))
(defun menu-bar-showhide-tool-bar-menu-customize-disable ()
  "Do not display tool bars."
  (interactive)
  (customize-set-variable 'tool-bar-mode nil))
(defun menu-bar-showhide-tool-bar-menu-customize-enable-left ()
  "Display tool bars on the left side."
  (interactive)
  (menu-bar-set-tool-bar-position 'left))
(defun menu-bar-showhide-tool-bar-menu-customize-enable-right ()
  "Display tool bars on the right side."
  (interactive)
  (menu-bar-set-tool-bar-position 'right))
(defun menu-bar-showhide-tool-bar-menu-customize-enable-top ()
  "Display tool bars on the top side."
  (interactive)
  (menu-bar-set-tool-bar-position 'top))
(defun menu-bar-showhide-tool-bar-menu-customize-enable-bottom ()
  "Display tool bars on the bottom side."
  (interactive)
  (menu-bar-set-tool-bar-position 'bottom))

(when (featurep 'move-toolbar)
  (defvar menu-bar-showhide-tool-bar-menu
    (let ((menu (make-sparse-keymap "Tool Bar")))

      (define-key menu [showhide-tool-bar-left]
        '(menu-item "On the Left"
                    menu-bar-showhide-tool-bar-menu-customize-enable-left
                    :help "Tool bar at the left side"
                    :visible (display-graphic-p)
                    :button
                    (:radio . (and tool-bar-mode
                                   (eq (frame-parameter
                                        (menu-bar-frame-for-menubar)
                                        'tool-bar-position)
                                       'left)))))

      (define-key menu [showhide-tool-bar-right]
        '(menu-item "On the Right"
                    menu-bar-showhide-tool-bar-menu-customize-enable-right
                    :help "Tool bar at the right side"
                    :visible (display-graphic-p)
                    :button
                    (:radio . (and tool-bar-mode
                                   (eq (frame-parameter
                                        (menu-bar-frame-for-menubar)
                                        'tool-bar-position)
                                       'right)))))

      (define-key menu [showhide-tool-bar-bottom]
        '(menu-item "On the Bottom"
                    menu-bar-showhide-tool-bar-menu-customize-enable-bottom
                    :help "Tool bar at the bottom"
                    :visible (display-graphic-p)
                    :button
                    (:radio . (and tool-bar-mode
                                   (eq (frame-parameter
                                        (menu-bar-frame-for-menubar)
                                        'tool-bar-position)
                                       'bottom)))))

      (define-key menu [showhide-tool-bar-top]
        '(menu-item "On the Top"
                    menu-bar-showhide-tool-bar-menu-customize-enable-top
                    :help "Tool bar at the top"
                    :visible (display-graphic-p)
                    :button
                    (:radio . (and tool-bar-mode
                                   (eq (frame-parameter
                                        (menu-bar-frame-for-menubar)
                                        'tool-bar-position)
                                       'top)))))

      (define-key menu [showhide-tool-bar-none]
        '(menu-item "None"
                    menu-bar-showhide-tool-bar-menu-customize-disable
                    :help "Turn tool bar off"
                    :visible (display-graphic-p)
                    :button (:radio . (eq tool-bar-mode nil))))
      menu)))

(defvar display-line-numbers-type)
(defun menu-bar-display-line-numbers-mode (type)
  (setq display-line-numbers-type type)
  (if global-display-line-numbers-mode
      (global-display-line-numbers-mode)
    (display-line-numbers-mode)))

(defun menu-bar--display-line-numbers-mode-visual ()
  "Turn on visual line number mode."
  (interactive)
  (menu-bar-display-line-numbers-mode 'visual)
  (message "Visual line numbers enabled"))

(defun menu-bar--display-line-numbers-mode-relative ()
  "Turn on relative line number mode."
  (interactive)
  (menu-bar-display-line-numbers-mode 'relative)
  (message "Relative line numbers enabled"))

(defun menu-bar--display-line-numbers-mode-absolute ()
  "Turn on absolute line number mode."
  (interactive)
  (menu-bar-display-line-numbers-mode t)
  (setq display-line-numbers t)
  (message "Absolute line numbers enabled"))

(defun menu-bar--display-line-numbers-mode-none ()
  "Disable line numbers."
  (interactive)
  (menu-bar-display-line-numbers-mode nil)
  (message "Line numbers disabled"))

(defvar menu-bar-showhide-line-numbers-menu
  (let ((menu (make-sparse-keymap "Line Numbers")))

    (define-key menu [visual]
      '(menu-item "Visual Line Numbers"
                  menu-bar--display-line-numbers-mode-visual
                  :help "Enable visual line numbers"
                  :button (:radio . (eq display-line-numbers 'visual))
                  :visible (menu-bar-menu-frame-live-and-visible-p)))

    (define-key menu [relative]
      '(menu-item "Relative Line Numbers"
                  menu-bar--display-line-numbers-mode-relative
                  :help "Enable relative line numbers"
                  :button (:radio . (eq display-line-numbers 'relative))
                  :visible (menu-bar-menu-frame-live-and-visible-p)))

    (define-key menu [absolute]
      '(menu-item "Absolute Line Numbers"
                  menu-bar--display-line-numbers-mode-absolute
                  :help "Enable absolute line numbers"
                  :button (:radio . (eq display-line-numbers t))
                  :visible (menu-bar-menu-frame-live-and-visible-p)))

    (define-key menu [none]
      '(menu-item "No Line Numbers"
                  menu-bar--display-line-numbers-mode-none
                  :help "Disable line numbers"
                  :button (:radio . (null display-line-numbers))
                  :visible (menu-bar-menu-frame-live-and-visible-p)))

    (define-key menu [global]
      (menu-bar-make-mm-toggle global-display-line-numbers-mode
                               "Global Line Numbers Mode"
                               "Set line numbers globally"))
    menu))

(defvar menu-bar-showhide-menu
  (let ((menu (make-sparse-keymap "Show/Hide")))

    (define-key menu [display-line-numbers]
      `(menu-item "Line Numbers for All Lines"
		  ,menu-bar-showhide-line-numbers-menu))

    (define-key menu [column-number-mode]
      (menu-bar-make-mm-toggle column-number-mode
                               "Column Numbers in Mode Line"
                               "Show the current column number in the mode line"))

    (define-key menu [line-number-mode]
      (menu-bar-make-mm-toggle line-number-mode
                               "Line Numbers in Mode Line"
                               "Show the current line number in the mode line"))

    (define-key menu [size-indication-mode]
      (menu-bar-make-mm-toggle size-indication-mode
                               "Size Indication"
                               "Show the size of the buffer in the mode line"))

    (define-key menu [linecolumn-separator]
      menu-bar-separator)

    (define-key menu [showhide-battery]
      (menu-bar-make-mm-toggle display-battery-mode
                               "Battery Status"
                               "Display battery status information in mode line"))

    (define-key menu [showhide-date-time]
      (menu-bar-make-mm-toggle display-time-mode
                               "Time, Load and Mail"
                               "Display time, system load averages and \
mail status in mode line"))

    (define-key menu [datetime-separator]
      menu-bar-separator)

    (define-key menu [showhide-speedbar]
      '(menu-item "Speedbar" speedbar-frame-mode
                  :help "Display a Speedbar quick-navigation frame"
                  :button (:toggle
                           . (and (boundp 'speedbar-frame)
                                  (frame-live-p (symbol-value 'speedbar-frame))
                                  (frame-visible-p
                                   (symbol-value 'speedbar-frame))))))

    (define-key menu [showhide-outline-minor-mode]
      '(menu-item "Outlines" outline-minor-mode
                  :help "Turn outline-minor-mode on/off"
                  :visible (seq-some #'local-variable-p
                                     '(outline-search-function
                                       outline-regexp outline-level))
                  :button (:toggle . (bound-and-true-p outline-minor-mode))))

    (define-key menu [showhide-tab-line-mode]
      '(menu-item "Window Tab Line" global-tab-line-mode
                  :help "Turn window-local tab-lines on/off"
                  :visible (fboundp 'global-tab-line-mode)
                  :button (:toggle . global-tab-line-mode)))

    (define-key menu [showhide-window-divider]
      `(menu-item "Window Divider" ,menu-bar-showhide-window-divider-menu
                  :visible (memq (window-system) '(x w32))))

    (define-key menu [showhide-fringe]
      `(menu-item "Fringe" ,menu-bar-showhide-fringe-menu
                  :visible (display-graphic-p)))

    (define-key menu [showhide-scroll-bar]
      `(menu-item "Scroll Bar" ,menu-bar-showhide-scroll-bar-menu
                  :visible (display-graphic-p)))

    (define-key menu [showhide-tooltip-mode]
      '(menu-item "Tooltips" tooltip-mode
                  :help "Turn tooltips on/off"
                  :visible (and (display-graphic-p) (fboundp 'x-show-tip))
                  :button (:toggle . tooltip-mode)))

    (define-key menu [showhide-context-menu]
      '(menu-item "Context Menus" context-menu-mode
                  :help "Turn mouse-3 context menus on/off"
                  :button (:toggle . context-menu-mode)))

    (define-key menu [menu-bar-mode]
      '(menu-item "Menu Bar" toggle-menu-bar-mode-from-frame
                  :help "Turn menu bar on/off"
                  :button
                  (:toggle . (menu-bar-positive-p
                              (frame-parameter (menu-bar-frame-for-menubar)
                                               'menu-bar-lines)))))

    (define-key menu [showhide-tab-bar]
      '(menu-item "Tab Bar" toggle-tab-bar-mode-from-frame
                  :help "Turn tab bar on/off"
                  :button
                  (:toggle . (menu-bar-positive-p
                              (frame-parameter (menu-bar-frame-for-menubar)
                                               'tab-bar-lines)))))

    (if (and (boundp 'menu-bar-showhide-tool-bar-menu)
             (keymapp menu-bar-showhide-tool-bar-menu))
        (define-key menu [showhide-tool-bar]
          `(menu-item "Tool Bar" ,menu-bar-showhide-tool-bar-menu
                      :visible (display-graphic-p)))
      ;; else not tool bar that can move.
      (define-key menu [showhide-tool-bar]
        '(menu-item "Tool Bar" toggle-tool-bar-mode-from-frame
                    :help "Turn tool bar on/off"
                    :visible (display-graphic-p)
                    :button
                    (:toggle . (menu-bar-positive-p
                                (frame-parameter (menu-bar-frame-for-menubar)
                                                 'tool-bar-lines))))))
    menu))

(defun menu-bar--visual-line-mode-enable ()
  "Enable visual line mode."
  (interactive)
  (unless visual-line-mode
    (visual-line-mode 1))
  (message "Visual-Line mode enabled"))

(defun menu-bar--toggle-truncate-long-lines ()
  "Toggle long lines mode."
  (interactive)
  (if visual-line-mode (visual-line-mode 0))
  (setq word-wrap nil)
  (toggle-truncate-lines 1))

(defun menu-bar--wrap-long-lines-window-edge ()
  "Wrap long lines at window edge."
  (interactive)
  (if visual-line-mode (visual-line-mode 0))
  (setq word-wrap nil)
  (if truncate-lines (toggle-truncate-lines -1)))

(defvar menu-bar-line-wrapping-menu
  (let ((menu (make-sparse-keymap "Line Wrapping")))

    (define-key menu [visual-wrap]
      '(menu-item "Visual Wrap Prefix mode" visual-wrap-prefix-mode
                  :help "Display continuation lines with visual context-dependent prefix"
                  :visible (menu-bar-menu-frame-live-and-visible-p)
                  :button (:toggle
                           . (bound-and-true-p visual-wrap-prefix-mode))
                  :enable t))

    (define-key menu [word-wrap]
      '(menu-item "Word Wrap (Visual Line mode)"
                  menu-bar--visual-line-mode-enable
                  :help "Wrap long lines at word boundaries"
                  :button (:radio
                           . (and (null truncate-lines)
                                  (not (truncated-partial-width-window-p))
                                  word-wrap))
                  :visible (menu-bar-menu-frame-live-and-visible-p)))

    (define-key menu [truncate]
      '(menu-item "Truncate Long Lines"
                  menu-bar--toggle-truncate-long-lines
                  :help "Truncate long lines at window edge"
                  :button (:radio . (or truncate-lines
                                        (truncated-partial-width-window-p)))
                  :visible (menu-bar-menu-frame-live-and-visible-p)
                  :enable (not (truncated-partial-width-window-p))))

    (define-key menu [window-wrap]
      '(menu-item "Wrap at Window Edge"
                  menu-bar--wrap-long-lines-window-edge
                  :help "Wrap long lines at window edge"
                  :button (:radio
                           . (and (null truncate-lines)
                                  (not (truncated-partial-width-window-p))
                                  (not word-wrap)))
                  :visible (menu-bar-menu-frame-live-and-visible-p)
                  :enable (not (truncated-partial-width-window-p))))
    menu))

(defvar menu-bar-search-options-menu
  (let ((menu (make-sparse-keymap "Search Options")))

    (dolist (x '((char-fold-to-regexp "Fold Characters" "Character folding")
                 (isearch-symbol-regexp "Whole Symbols" "Whole symbol")
                 (word-search-regexp "Whole Words" "Whole word")))
      (define-key menu (vector (nth 0 x))
        `(menu-item ,(nth 1 x)
                    ,(lambda ()
                       (interactive)
                       (setq search-default-mode (nth 0 x))
                       (message "%s search enabled" (nth 2 x)))
                    :help ,(format "Enable %s search" (downcase (nth 2 x)))
                    :button (:radio . (eq search-default-mode #',(nth 0 x))))))

    (define-key menu [regexp-search]
      `(menu-item "Regular Expression"
                  ,(lambda ()
                     (interactive)
                     (setq search-default-mode t)
                     (message "Regular-expression search enabled"))
                  :help "Enable regular-expression search"
                  :button (:radio . (eq search-default-mode t))))

    (define-key menu [regular-search]
      `(menu-item "Literal Search"
                  ,(lambda ()
                     (interactive)
                     (when search-default-mode
                       (setq search-default-mode nil)
                       (when (symbolp search-default-mode)
                         (message "Literal search enabled"))))
                  :help "Disable special search modes"
                  :button (:radio . (not search-default-mode))))

    (define-key menu [custom-separator]
      menu-bar-separator)
    (define-key menu [case-fold-search]
      (menu-bar-make-toggle-command
       toggle-case-fold-search case-fold-search
       "Ignore Case"
       "Case-Insensitive Search %s"
       "Ignore letter-case in search commands"))

    menu))

(defvar menu-bar-options-menu
  (let ((menu (make-sparse-keymap "Options")))
    (define-key menu [customize]
      `(menu-item "Customize Emacs" ,menu-bar-custom-menu))

    (define-key menu [package]
      '(menu-item "Manage Emacs Packages" package-list-packages
        :help "Install or uninstall additional Emacs packages"))

    (define-key menu [save]
      '(menu-item "Save Options" menu-bar-options-save
                  :help "Save options set from the menu above"))

    (define-key menu [custom-separator]
      menu-bar-separator)

    (define-key menu [menu-set-font]
      '(menu-item "Set Default Font..." menu-set-font
                  :visible (display-multi-font-p)
                  :help "Select a default font"))

    (if (featurep 'system-font-setting)
        (define-key menu [menu-system-font]
          (menu-bar-make-toggle-command
           toggle-use-system-font font-use-system-font
           "Use System Font"
           "Use system font: %s"
           "Use the monospaced font defined by the system")))

    (define-key menu [showhide]
      `(menu-item "Show/Hide" ,menu-bar-showhide-menu))

    (define-key menu [showhide-separator]
      menu-bar-separator)

    (define-key menu [mule]
      ;; It is better not to use backquote here,
      ;; because that makes a bootstrapping problem
      ;; if you need to recompile all the Lisp files using interpreted code.
      `(menu-item "Multilingual Environment" ,mule-menu-keymap))
    ;;(setq menu-bar-final-items (cons 'mule menu-bar-final-items))
    ;;(define-key menu [preferences]
    ;;  `(menu-item "Preferences" ,menu-bar-preferences-menu
    ;;	      :help "Toggle important global options"))

    (define-key menu [mule-separator]
      menu-bar-separator)

    (define-key menu [debug-on-quit]
      (menu-bar-make-toggle-command
       toggle-debug-on-quit debug-on-quit
       "Enter Debugger on Quit/C-g" "Debug on Quit %s"
       "Enter Lisp debugger when C-g is pressed"))
    (define-key menu [debug-on-error]
      (menu-bar-make-toggle-command
       toggle-debug-on-error debug-on-error
       "Enter Debugger on Error" "Debug on Error %s"
       "Enter Lisp debugger when an error is signaled"))
    (define-key menu [debugger-separator]
      menu-bar-separator)

    (define-key menu [blink-cursor-mode]
      (menu-bar-make-mm-toggle
       blink-cursor-mode
       "Blink Cursor"
       "Whether the cursor blinks (Blink Cursor mode)"))
    (define-key menu [cursor-separator]
      menu-bar-separator)

    (define-key menu [save-desktop]
      (menu-bar-make-toggle-command
       toggle-save-desktop-globally desktop-save-mode
       "Save State between Sessions"
       "Saving desktop state %s"
       "Visit desktop of previous session when restarting Emacs"
       (progn
         (require 'desktop)
         ;; Do it by name, to avoid a free-variable
         ;; warning during byte compilation.
         (set-default
	  'desktop-save-mode (not (symbol-value 'desktop-save-mode))))))

    (define-key menu [save-place]
      (menu-bar-make-toggle-command
       toggle-save-place-globally save-place-mode
       "Save Place in Files between Sessions"
       "Saving place in files %s"
       "Visit files of previous session when restarting Emacs"
       (progn
         (require 'saveplace)
         ;; Do it by name, to avoid a free-variable
         ;; warning during byte compilation.
         (set-default
	  'save-place-mode (not (symbol-value 'save-place-mode))))))

    (define-key menu [uniquify]
      (menu-bar-make-toggle-command
       toggle-uniquify-buffer-names uniquify-buffer-name-style
       "Use Directory Names in Buffer Names"
       "Directory name in buffer names (uniquify) %s"
       "Uniquify buffer names by adding parent directory names"
       (setq uniquify-buffer-name-style
	     (if (not uniquify-buffer-name-style)
		 'post-forward-angle-brackets))))

    (define-key menu [edit-options-separator]
      menu-bar-separator)
    (define-key menu [cua-mode]
      (menu-bar-make-mm-toggle
       cua-mode
       "Cut/Paste with C-x/C-c/C-v (CUA Mode)"
       "Use C-z/C-x/C-c/C-v keys for undo/cut/copy/paste"
       (:visible (or (not (boundp 'cua-enable-cua-keys))
		     cua-enable-cua-keys))))

    (define-key menu [cua-emulation-mode]
      (menu-bar-make-mm-toggle
       cua-mode
       "CUA Mode (without C-x/C-c/C-v)"
       "Enable CUA Mode without rebinding C-x/C-c/C-v keys"
       (:visible (and (boundp 'cua-enable-cua-keys)
		      (not cua-enable-cua-keys)))))

    (define-key menu [search-options]
      `(menu-item "Default Search Options"
		  ,menu-bar-search-options-menu))

    (define-key menu [line-wrapping]
      `(menu-item "Line Wrapping in This Buffer"
		  ,menu-bar-line-wrapping-menu))


    (define-key menu [highlight-separator]
      menu-bar-separator)
    (define-key menu [highlight-paren-mode]
      (menu-bar-make-mm-toggle
       show-paren-mode
       "Highlight Matching Parentheses"
       "Highlight matching/mismatched parentheses at cursor (Show Paren mode)"))
    (define-key menu [transient-mark-mode]
      (menu-bar-make-mm-toggle
       transient-mark-mode
       "Highlight Active Region"
       "Make text in active region stand out in color (Transient Mark mode)"
       (:enable (not cua-mode))))
    menu))


;; The "Tools" menu items

(defvar menu-bar-games-menu
  (let ((menu (make-sparse-keymap "Games")))

    (define-key menu [zone]
      '(menu-item "Zone Out" zone
                  :help "Play tricks with Emacs display when Emacs is idle"))
    (define-key menu [tetris]
      '(menu-item "Tetris" tetris
                  :help "Falling blocks game"))
    (define-key menu [solitaire]
      '(menu-item "Solitaire" solitaire
                  :help "Get rid of all the stones"))
    (define-key menu [snake]
      '(menu-item "Snake" snake
                  :help "Move snake around avoiding collisions"))
    (define-key menu [pong]
      '(menu-item "Pong" pong
                  :help "Bounce the ball to your opponent"))
    (define-key menu [mult]
      '(menu-item "Multiplication Puzzle"  mpuz
                  :help "Exercise brain with multiplication"))
    (define-key menu [life]
      '(menu-item "Life"  life
                  :help "Watch how John Conway's cellular automaton evolves"))
    (define-key menu [hanoi]
      '(menu-item "Towers of Hanoi" hanoi
                  :help "Watch Towers-of-Hanoi puzzle solved by Emacs"))
    (define-key menu [gomoku]
      '(menu-item "Gomoku"  gomoku
                  :help "Mark 5 contiguous squares (like tic-tac-toe)"))
    (define-key menu [bubbles]
      '(menu-item "Bubbles" bubbles
                  :help "Remove all bubbles using the fewest moves"))
    (define-key menu [black-box]
      '(menu-item "Blackbox"  blackbox
                  :help "Find balls in a black box by shooting rays"))
    (define-key menu [adventure]
      '(menu-item "Adventure"  dunnet
                  :help "Dunnet, a text Adventure game for Emacs"))
    (define-key menu [5x5]
      '(menu-item "5x5" 5x5
                  :help "Fill in all the squares on a 5x5 board"))
    menu))

(defvar menu-bar-encryption-decryption-menu
  (let ((menu (make-sparse-keymap "Encryption/Decryption")))
    (define-key menu [insert-keys]
      '(menu-item "Insert Keys" epa-insert-keys
                  :help "Insert public keys after the current point"))

    (define-key menu [export-keys]
      '(menu-item "Export Keys" epa-export-keys
                  :help "Export public keys to a file"))

    (define-key menu [import-keys-region]
      '(menu-item "Import Keys from Region" epa-import-keys-region
                  :help "Import public keys from the current region"))

    (define-key menu [import-keys]
      '(menu-item "Import Keys from File..." epa-import-keys
                  :help "Import public keys from a file"))

    (define-key menu [list-keys]
      '(menu-item "List Keys" epa-list-keys
                  :help "Browse your public keyring"))

    (define-key menu [separator-keys]
      menu-bar-separator)

    (define-key menu [sign-region]
      '(menu-item "Sign Region" epa-sign-region
                  :help "Create digital signature of the current region"))

    (define-key menu [verify-region]
      '(menu-item "Verify Region" epa-verify-region
                  :help "Verify digital signature of the current region"))

    (define-key menu [encrypt-region]
      '(menu-item "Encrypt Region" epa-encrypt-region
                  :help "Encrypt the current region"))

    (define-key menu [decrypt-region]
      '(menu-item "Decrypt Region" epa-decrypt-region
                  :help "Decrypt the current region"))

    (define-key menu [separator-file]
      menu-bar-separator)

    (define-key menu [sign-file]
      '(menu-item "Sign File..." epa-sign-file
                  :help "Create digital signature of a file"))

    (define-key menu [verify-file]
      '(menu-item "Verify File..." epa-verify-file
                  :help "Verify digital signature of a file"))

    (define-key menu [encrypt-file]
      '(menu-item "Encrypt File..." epa-encrypt-file
                  :help "Encrypt a file"))

    (define-key menu [decrypt-file]
      '(menu-item "Decrypt File..." epa-decrypt-file
                  :help "Decrypt a file"))

    menu))

(defvar menu-bar-shell-commands-menu
  (let ((menu (make-sparse-keymap "Shell Commands")))
    (define-key menu [project-interactive-shell]
      '(menu-item "Run Shell In Project" project-shell
                  :help "Run a subshell interactively, in the current project's root directory"))

    (define-key menu [interactive-shell]
      '(menu-item "Run Shell" shell
                  :help "Run a subshell interactively"))

    (define-key menu [async-shell-command]
      '(menu-item "Async Shell Command..." async-shell-command
                  :help "Invoke a shell command asynchronously in background"))

    (define-key menu [shell-on-region]
      '(menu-item "Shell Command on Region..." shell-command-on-region
                  :enable mark-active
                  :help "Pass marked region to a shell command"))

    (define-key menu [shell]
      '(menu-item "Shell Command..." shell-command
                  :help "Invoke a shell command and catch its output"))

    menu))

(defvar menu-bar-project-menu
  (let ((menu (make-sparse-keymap "Project")))
    (define-key menu [project-execute-extended-command] '(menu-item "Execute Extended Command..." project-execute-extended-command :help "Execute an extended command in project root directory"))
    (define-key menu [project-query-replace-regexp] '(menu-item "Query Replace Regexp..." project-query-replace-regexp :help "Interactively replace a regexp in files belonging to current project"))
    (define-key menu [project-or-external-find-regexp] '(menu-item "Find Regexp Including External Roots..." project-or-external-find-regexp :help "Search for a regexp in files belonging to current project or external files"))
    (define-key menu [project-find-regexp] '(menu-item "Find Regexp..." project-find-regexp :help "Search for a regexp in files belonging to current project"))
    (define-key menu [separator-project-search] menu-bar-separator)
    (define-key menu [project-kill-buffers] '(menu-item "Kill Buffers..." project-kill-buffers :help "Kill the buffers belonging to the current project"))
    (define-key menu [project-list-buffers] '(menu-item "List Buffers" project-list-buffers :help "Pop up a window listing all Emacs buffers belonging to current project"))
    (define-key menu [project-switch-to-buffer] '(menu-item "Switch To Buffer..." project-switch-to-buffer :help "Prompt for a buffer belonging to current project, and switch to it"))
    (define-key menu [separator-project-buffers] menu-bar-separator)
    (define-key menu [project-async-shell-command] '(menu-item "Async Shell Command..." project-async-shell-command :help "Invoke a shell command in project root asynchronously in background"))
    (define-key menu [project-shell-command] '(menu-item "Shell Command..." project-shell-command :help "Invoke a shell command in project root and catch its output"))
    (define-key menu [project-eshell] '(menu-item "Run Eshell" project-eshell :help "Run eshell for the current project"))
    (define-key menu [project-shell] '(menu-item "Run Shell" project-shell :help "Run a subshell interactively, in the current project's root directory"))
    (define-key menu [project-compile] '(menu-item "Compile..." project-compile :help "Invoke compiler or Make for current project, view errors"))
    (define-key menu [separator-project-programs] menu-bar-separator)
    (define-key menu [project-switch-project] '(menu-item "Switch Project..." project-switch-project :help "Switch to another project and then run a command"))
    (define-key menu [project-customize-dirlocals] '(menu-item "Customize Directory Local Variables" project-customize-dirlocals :help "Customize current project Directory Local Variables."))
    (define-key menu [project-vc-dir] '(menu-item "VC Dir" project-vc-dir :help "Show the VC status of the project repository"))
    (define-key menu [project-dired] '(menu-item "Open Project Root" project-dired :help "Read the root directory of the current project, to operate on its files"))
    (define-key menu [project-find-dir] '(menu-item "Open Directory..." project-find-dir :help "Open existing directory that belongs to current project"))
    (define-key menu [project-or-external-find-file] '(menu-item "Open File Including External Roots..." project-or-external-find-file :help "Open existing file that belongs to current project or its external roots"))
    (define-key menu [project-open-file] '(menu-item "Open File..." project-find-file :help "Open an existing file that belongs to current project"))
    menu))

(defvar menu-bar-project-item
  `(menu-item "Project" ,menu-bar-project-menu))

(defun menu-bar-read-mail ()
  "Read mail using `read-mail-command'."
  (interactive)
  (call-interactively read-mail-command))

(defvar menu-bar-tools-menu
  (let ((menu (make-sparse-keymap "Tools")))

    (define-key menu [games]
      `(menu-item "Games" ,menu-bar-games-menu))

    (define-key menu [separator-games]
      menu-bar-separator)

    (define-key menu [encryption-decryption]
      `(menu-item "Encryption/Decryption"
                  ,menu-bar-encryption-decryption-menu))

    (define-key menu [separator-encryption-decryption]
      menu-bar-separator)

    (define-key menu [simple-calculator]
      '(menu-item "Simple Calculator" calculator
                  :help "Invoke the Emacs built-in quick calculator"))
    (define-key menu [calc]
      '(menu-item "Programmable Calculator" calc
                  :help "Invoke the Emacs built-in full scientific calculator"))
    (define-key menu [calendar]
      '(menu-item "Calendar" calendar
                  :help "Invoke the Emacs built-in calendar"))

    (define-key menu [separator-net]
      menu-bar-separator)

    (define-key menu [browse-web]
      '(menu-item "Browse the Web..." browse-web))
    (define-key menu [directory-search]
      '(menu-item "Directory Servers" eudc-tools-menu))
    (define-key menu [compose-mail]
      '(menu-item "Compose New Mail" compose-mail
                  :visible (and mail-user-agent (not (eq mail-user-agent 'ignore)))
                  :help "Start writing a new mail message"))
    (define-key menu [rmail]
      '(menu-item "Read Mail" menu-bar-read-mail
                  :visible (and read-mail-command
                                (not (eq read-mail-command 'ignore)))
                  :help "Read your mail"))

    (define-key menu [gnus]
      '(menu-item "Read Net News" gnus
                  :help "Read network news groups"))

    (define-key menu [separator-vc]
      menu-bar-separator)

    (define-key menu [vc] nil) ;Create the place for the VC menu.

    (define-key menu [separator-compare]
      menu-bar-separator)

    (define-key menu [epatch]
      '(menu-item "Apply Patch" menu-bar-epatch-menu))
    (define-key menu [ediff-merge]
      '(menu-item "Merge" menu-bar-ediff-merge-menu))
    (define-key menu [compare]
      '(menu-item "Compare (Ediff)" menu-bar-ediff-menu))

    (define-key menu [separator-spell]
      menu-bar-separator)

    (define-key menu [spell]
      '(menu-item "Spell Checking" ispell-menu-map))

    (define-key menu [separator-prog]
      menu-bar-separator)

    (define-key menu [semantic]
      '(menu-item "Source Code Parsers (Semantic)"
                  semantic-mode
                  :help "Toggle automatic parsing in source code buffers (Semantic mode)"
                  :button (:toggle . (bound-and-true-p semantic-mode))))

    (define-key menu [ede]
      '(menu-item "Project Support (EDE)"
                  global-ede-mode
                  :help "Toggle the Emacs Development Environment (Global EDE mode)"
                  :button (:toggle . (bound-and-true-p global-ede-mode))))

    (define-key menu [eglot]
      '(menu-item "Language Server Support (Eglot)" eglot
                  :help "Start language server suitable for this buffer's major-mode"))

    (define-key menu [project]
      menu-bar-project-item)

    (define-key menu [gdb]
      '(menu-item "Debugger (GDB)..." gdb
                  :help "Debug a program from within Emacs with GDB"))
    (define-key menu [project-compile]
      '(menu-item "Compile Project..." project-compile
                  :help "Invoke compiler or Make for current project, view errors"))

    (define-key menu [compile]
      '(menu-item "Compile..." compile
                  :help "Invoke compiler or Make in current buffer's directory, view errors"))

    (define-key menu [shell-commands]
      `(menu-item "Shell Commands"
                  ,menu-bar-shell-commands-menu))

    (define-key menu [rgrep]
      '(menu-item "Recursive Grep..." rgrep
                  :help "Interactively ask for parameters and search recursively"))
    (define-key menu [grep]
      '(menu-item "Search Files (Grep)..." grep
                  :help "Search files for strings or regexps (with Grep)"))
    menu))

;; The "Help" menu items

(defvar menu-bar-describe-menu
  (let ((menu (make-sparse-keymap "Describe")))

    (define-key menu [mule-diag]
      '(menu-item "Show All of Mule Status" mule-diag
                  :help "Display multilingual environment settings"))
    (define-key menu [describe-coding-system-briefly]
      '(menu-item "Describe Coding System (Briefly)"
                  describe-current-coding-system-briefly))
    (define-key menu [describe-coding-system]
      '(menu-item "Describe Coding System..." describe-coding-system))
    (define-key menu [describe-input-method]
      '(menu-item "Describe Input Method..." describe-input-method
                  :help "Keyboard layout for specific input method"))
    (define-key menu [describe-language-environment]
      `(menu-item "Describe Language Environment"
                  ,describe-language-environment-map))

    (define-key menu [separator-desc-mule]
      menu-bar-separator)

    (define-key menu [list-keybindings]
      '(menu-item "List Key Bindings" describe-bindings
                  :help "Display all current key bindings (keyboard shortcuts)"))
    (define-key menu [list-recent-keystrokes]
      '(menu-item "Show Recent Inputs" view-lossage
                  :help "Display last few input events and the commands \
they ran"))
    (define-key menu [describe-current-display-table]
      '(menu-item "Describe Display Table" describe-current-display-table
                  :help "Describe the current display table"))
    (define-key menu [describe-package]
      '(menu-item "Describe Package..." describe-package
                  :help "Display documentation of a Lisp package"))
    (define-key menu [describe-face]
      '(menu-item "Describe Face..." describe-face
                  :help "Display the properties of a face"))
    (define-key menu [describe-variable]
      '(menu-item "Describe Variable..." describe-variable
                  :help "Display documentation of variable/option"))
    (define-key menu [describe-function]
      '(menu-item "Describe Function..." describe-function
                  :help "Display documentation of function/command"))
    (define-key menu [describe-command]
      '(menu-item "Describe Command..." describe-command
                  :help "Display documentation of command"))
    (define-key menu [shortdoc-display-group]
      '(menu-item "Function Group Overview..." shortdoc-display-group
                  :help "Display a function overview for a specific topic"))
    (define-key menu [describe-key-1]
      '(menu-item "Describe Key or Mouse Operation..." describe-key
                  ;; Users typically don't identify keys and menu items...
                  :help "Display documentation of command bound to a \
key, a click, or a menu-item"))
    (define-key menu [describe-mode]
      '(menu-item "Describe Buffer Modes" describe-mode
                  :help "Describe this buffer's major and minor mode"))
    menu))

(defun menu-bar-read-lispref ()
  "Display the Emacs Lisp Reference manual in Info mode."
  (interactive)
  (info "elisp"))

(defun menu-bar-read-lispintro ()
  "Display the Introduction to Emacs Lisp Programming in Info mode."
  (interactive)
  (info "eintr"))

(defun search-emacs-glossary ()
  "Display the Glossary node of the Emacs manual in Info mode."
  (interactive)
  (info "(emacs)Glossary"))

(defun emacs-index--prompt ()
  (let* ((default (thing-at-point 'sexp))
         (topic
          (read-from-minibuffer
           (format-prompt "Subject to look up" default)
           nil nil nil nil default)))
    (list (if (zerop (length topic))
              default
            topic))))

(defun emacs-index-search (topic)
  "Look up TOPIC in the indices of the Emacs User Manual."
  (interactive (emacs-index--prompt))
  (info "emacs")
  (Info-index topic))

(defun elisp-index-search (topic)
  "Look up TOPIC in the indices of the Emacs Lisp Reference Manual."
  (interactive (emacs-index--prompt))
  (info "elisp")
  (Info-index topic))

(defvar menu-bar-search-documentation-menu
  (let ((menu (make-sparse-keymap "Search Documentation")))

    (define-key menu [search-documentation-strings]
      '(menu-item "Search Documentation Strings..." apropos-documentation
                  :help
                  "Find functions and variables whose doc strings match a regexp"))
    (define-key menu [find-any-object-by-name]
      '(menu-item "Find Any Object by Name..." apropos
                  :help "Find symbols of any kind whose names match a regexp"))
    (define-key menu [find-option-by-value]
      '(menu-item "Find Options by Value..." apropos-value
                  :help "Find variables whose values match a regexp"))
    (define-key menu [find-options-by-name]
      '(menu-item "Find Options by Name..." apropos-user-option
                  :help "Find user options whose names match a regexp"))
    (define-key menu [find-commands-by-name]
      '(menu-item "Find Commands by Name..." apropos-command
                  :help "Find commands whose names match a regexp"))
    (define-key menu [sep1]
      menu-bar-separator)
    (define-key menu [lookup-symbol-in-manual]
      '(menu-item "Look Up Symbol in Manual..." info-lookup-symbol
                  :help "Display manual section that describes a symbol"))
    (define-key menu [lookup-command-in-manual]
      '(menu-item "Look Up Command in User Manual..." Info-goto-emacs-command-node
                  :help "Display manual section that describes a command"))
    (define-key menu [lookup-key-in-manual]
      '(menu-item "Look Up Key in User Manual..." Info-goto-emacs-key-command-node
                  :help "Display manual section that describes a key"))
    (define-key menu [lookup-subject-in-elisp-manual]
      '(menu-item "Look Up Subject in Elisp Manual..." elisp-index-search
                  :help "Find description of a subject in Emacs Lisp manual"))
    (define-key menu [lookup-subject-in-emacs-manual]
      '(menu-item "Look Up Subject in User Manual..." emacs-index-search
                  :help "Find description of a subject in Emacs User manual"))
    (define-key menu [emacs-terminology]
      '(menu-item "Emacs Terminology" search-emacs-glossary
                  :help "Display the Glossary section of the Emacs manual"))
    menu))

(defvar menu-bar-manuals-menu
  (let ((menu (make-sparse-keymap "More Manuals")))

    (define-key menu [man]
      '(menu-item "Read Man Page..." manual-entry
                  :help "Man-page docs for external commands and libraries"))
    (define-key menu [sep2]
      menu-bar-separator)
    (define-key menu [order-emacs-manuals]
      '(menu-item "Ordering Manuals" view-order-manuals
                  :help "How to order manuals from the Free Software Foundation"))
    (define-key menu [lookup-subject-in-all-manuals]
      '(menu-item "Lookup Subject in all Manuals..." info-apropos
                  :help "Find description of a subject in all installed manuals"))
    (define-key menu [other-manuals]
      '(menu-item "All Other Manuals (Info)" Info-directory
                  :help "Read any of the installed manuals"))
    (define-key menu [emacs-lisp-reference]
      '(menu-item "Emacs Lisp Reference" menu-bar-read-lispref
                  :help "Read the Emacs Lisp Reference manual"))
    (define-key menu [emacs-lisp-intro]
      '(menu-item "Introduction to Emacs Lisp" menu-bar-read-lispintro
                  :help "Read the Introduction to Emacs Lisp Programming"))
    menu))

(defun help-with-tutorial-spec-language ()
  "Use the Emacs tutorial, specifying which language you want."
  (interactive)
  (help-with-tutorial t))

(defvar menu-bar-help-menu
  (let ((menu (make-sparse-keymap "Help")))
    (define-key menu [about-gnu-project]
      '(menu-item "About GNU" describe-gnu-project
                  :help "About the GNU System, GNU Project, and GNU/Linux"))
    (define-key menu [about-emacs]
      '(menu-item "About Emacs" about-emacs
                  :help "Display version number, copyright info, and basic help"))
    (define-key menu [sep4]
      menu-bar-separator)
    (define-key menu [describe-no-warranty]
      '(menu-item "(Non)Warranty" describe-no-warranty
                  :help "Explain that Emacs has NO WARRANTY"))
    (define-key menu [describe-copying]
      '(menu-item "Copying Conditions" describe-copying
                  :help "Show the Emacs license (GPL)"))
    (define-key menu [getting-new-versions]
      '(menu-item "Getting New Versions" describe-distribution
                  :help "How to get the latest version of Emacs"))
    (define-key menu [sep2]
      menu-bar-separator)
    (define-key menu [external-packages]
      '(menu-item "Finding Extra Packages" view-external-packages
                  :help "How to get more Lisp packages for use in Emacs"))
    (define-key menu [find-emacs-packages]
      '(menu-item "Search Built-in Packages" finder-by-keyword
                  :help "Find built-in packages and features by keyword"))
    (define-key menu [more-manuals]
      `(menu-item "More Manuals" ,menu-bar-manuals-menu))
    (define-key menu [emacs-manual]
      '(menu-item "Read the Emacs Manual" info-emacs-manual
                  :help "Full documentation of Emacs features"))
    (define-key menu [describe]
      `(menu-item "Describe" ,menu-bar-describe-menu))
    (define-key menu [search-documentation]
      `(menu-item "Search Documentation" ,menu-bar-search-documentation-menu))
    (define-key menu [sep1]
      menu-bar-separator)
    (define-key menu [emacs-psychotherapist]
      '(menu-item "Emacs Psychotherapist" doctor
                  :help "Our doctor will help you feel better"))
    (define-key menu [send-emacs-bug-report]
      '(menu-item "Send Bug Report..." report-emacs-bug
                  :help "Send e-mail to Emacs maintainers"))
    (define-key menu [emacs-manual-bug]
      '(menu-item "How to Report a Bug" info-emacs-bug
                  :help "Read about how to report an Emacs bug"))
    (define-key menu [emacs-known-problems]
      '(menu-item "Emacs Known Problems" view-emacs-problems
                  :help "Read about known problems with Emacs"))
    (define-key menu [emacs-news]
      '(menu-item "Emacs News" view-emacs-news
                  :help "New features of this version"))
    (define-key menu [emacs-faq]
      '(menu-item "Emacs FAQ" view-emacs-FAQ
                  :help "Frequently asked (and answered) questions about Emacs"))

    (define-key menu [emacs-tutorial-language-specific]
      '(menu-item "Emacs Tutorial (choose language)..."
                  help-with-tutorial-spec-language
                  :help "Learn how to use Emacs (choose a language)"))
    (define-key menu [emacs-tutorial]
      '(menu-item "Emacs Tutorial" help-with-tutorial
                  :help "Learn how to use Emacs"))

    ;; In macOS it's in the app menu already.
    ;; FIXME? There already is an "About Emacs" (sans ...) entry in the Help menu.
    (and (featurep 'ns)
         (not (eq system-type 'darwin))
         (define-key menu [info-panel]
           '(menu-item "About Emacs..." ns-do-emacs-info-panel)))
    menu))

(define-key global-map [menu-bar tools]
  (cons "Tools" menu-bar-tools-menu))
(define-key global-map [menu-bar buffer]
  (cons "Buffers" global-buffers-menu-map))
(define-key global-map [menu-bar options]
  (cons "Options" menu-bar-options-menu))
(define-key global-map [menu-bar edit]
  (cons "Edit" menu-bar-edit-menu))
(define-key global-map [menu-bar file]
  (cons "File" menu-bar-file-menu))
(define-key global-map [menu-bar help-menu]
  (cons "Help" menu-bar-help-menu))

(define-key global-map [menu-bar mouse-1] 'menu-bar-open-mouse)

(defun menu-bar-menu-frame-live-and-visible-p ()
  "Return non-nil if the menu frame is alive and visible.
The menu frame is the frame for which we are updating the menu."
  (let ((menu-frame (or menu-updating-frame (selected-frame))))
    (and (frame-live-p menu-frame)
	 (frame-visible-p menu-frame))))

(defun menu-bar-non-minibuffer-window-p ()
  "Return non-nil if the menu frame's selected window is no minibuffer window.
Return nil if the menu frame is dead or its selected window is a
minibuffer window.  The menu frame is the frame for which we are
updating the menu."
  (let ((menu-frame (or menu-updating-frame (selected-frame))))
    (and (frame-live-p menu-frame)
	 (not (window-minibuffer-p
	       (frame-selected-window menu-frame))))))

(defun kill-this-buffer ()
  "Kill the current buffer.
When called in the minibuffer, get out of the minibuffer
using `abort-recursive-edit'.

This command can be invoked only from a menu or a tool bar.  If you want
to invoke a similar command with `M-x', use `kill-current-buffer'."
  (interactive)
  ;; This colossus of a conditional is necessary to account for the wide
  ;; variety of this command's callers.
  (if (let ((lce last-command-event))
        (eq (cond
             ((atom lce)                ; Selected menu item.
              lce)
             ((mouse-event-p lce)       ; Clicked window tool bar icon.
              ;; Code from window-tool-bar--call-button.
              (let* ((posn (event-start lce))
                     (str (posn-string posn)))
                (get-text-property (cdr str) 'tool-bar-key (car str))))
             (t
              (car lce)))               ; Clicked tool bar icon.
            'kill-buffer))
      (if (let* ((window (or (posn-window (event--posn-at-point))
                             last-event-frame
                            (selected-frame)))
                (frame (if (framep window) window
                         (window-frame window))))
           (not (window-minibuffer-p (frame-selected-window frame))))
         (progn (kill-buffer (current-buffer))
                ;; Also close the current window if
                ;; `menu-bar-close-window' is set.
                (when menu-bar-close-window
                  (ignore-errors (delete-window))))
        (abort-recursive-edit))
    (error "This command must be called from a menu or a tool bar")))

(defun kill-this-buffer-enabled-p ()
  "Return non-nil if the `kill-this-buffer' menu item should be enabled.
It should be enabled there is at least one non-hidden buffer, or if
`menu-bar-close-window' is non-nil and there is more than one window on
this frame."
  (or (not (menu-bar-non-minibuffer-window-p))
      (let (found-1)
	;; Instead of looping over entire buffer list, stop once we've
	;; found two "killable" buffers (Bug#8184).
	(catch 'found-2
	  (dolist (buffer (buffer-list))
	    (unless (string-match-p "^ " (buffer-name buffer))
	      (if (not found-1)
		  (setq found-1 t)
		(throw 'found-2 t))))))
      (and menu-bar-close-window
           (window-parent (selected-window)))))

(put 'dired 'menu-enable '(menu-bar-non-minibuffer-window-p))

;; Permit deleting frame if it would leave a visible or iconified frame.
(defun delete-frame-enabled-p ()
  "Return non-nil if `delete-frame' should be enabled in the menu bar."
  (let ((frames (frame-list))
	(count 0))
    (while frames
      (if (frame-visible-p (car frames))
	  (setq count (1+ count)))
      (setq frames (cdr frames)))
    (> count 1)))

(defcustom yank-menu-length 20
  "Text of items in `yank-menu' longer than this will be truncated."
  :type 'natnum
  :group 'menu)

(defcustom yank-menu-max-items 60
  "Maximum number of entries to display in the `yank-menu'."
  :type 'natnum
  :group 'menu
  :version "29.1")

(defun menu-bar-update-yank-menu (string old)
  (let ((front (car (cdr yank-menu)))
	(menu-string (if (<= (length string) yank-menu-length)
			 string
		       (concat
			(substring string 0 (/ yank-menu-length 2))
			"..."
			(substring string (- (/ yank-menu-length 2)))))))
    ;; Don't let the menu string be all dashes
    ;; because that has a special meaning in a menu.
    (if (string-match "\\`-+\\'" menu-string)
	(setq menu-string (concat menu-string " ")))
    ;; If we're supposed to be extending an existing string, and that
    ;; string really is at the front of the menu, then update it in place.
    (if (and old (or (eq old (car front))
		     (string= old (car front))))
	(progn
	  (setcar front string)
	  (setcar (cdr front) menu-string))
      (setcdr yank-menu
	      (cons
	       (cons string (cons menu-string 'menu-bar-select-yank))
	       (cdr yank-menu)))))
  (let ((max-items (min yank-menu-max-items kill-ring-max)))
    (if (> (length (cdr yank-menu)) max-items)
        (setcdr (nthcdr max-items yank-menu) nil))))

(put 'menu-bar-select-yank 'apropos-inhibit t)
(defun menu-bar-select-yank ()
  "Insert the stretch of previously-killed text selected from menu.
The menu shows all the killed text sequences stored in `kill-ring'."
  (interactive "*")
  (push-mark)
  (insert last-command-event))


;;; Buffers Menu

;; Increasing this more might be problematic on TTY frames.  See Bug#64398.
(defcustom buffers-menu-max-size 15
  "Maximum number of entries which may appear on the Buffers menu.
If this is a number, only that many most-recently-selected
buffers are shown.
If this is nil, all buffers are shown."
  :type '(choice natnum
                 (const :tag "All" nil))
  :group 'menu
  :version "30.1")

(defcustom buffers-menu-buffer-name-length 30
  "Maximum length of the buffer name on the Buffers menu.
If this is a number, then buffer names are truncated to this length.
If this is nil, then buffer names are shown in full.
A large number or nil makes the menu too wide."
  :type '(choice integer
		 (const :tag "Full length" nil))
  :group 'menu)

(defcustom buffers-menu-show-directories 'unless-uniquify
  "If non-nil, show directories in the Buffers menu for buffers that have them.
The special value `unless-uniquify' means that directories will be shown
unless `uniquify-buffer-name-style' is non-nil (in which case, buffer
names should include enough of a buffer's directory to distinguish it
from other buffers).

Setting this variable directly does not take effect until next time the
Buffers menu is regenerated."
  :set (lambda (symbol value)
	 (set symbol value)
	 (menu-bar-update-buffers t))
  :initialize 'custom-initialize-default
  :type '(choice (const :tag "Never" nil)
		 (const :tag "Unless uniquify is enabled" unless-uniquify)
		 (const :tag "Always" t))
  :group 'menu)

(defcustom buffers-menu-show-status t
  "If non-nil, show modified/read-only status of buffers in the Buffers menu.
Setting this variable directly does not take effect until next time the
Buffers menu is regenerated."
  :set (lambda (symbol value)
	 (set symbol value)
	 (menu-bar-update-buffers t))
  :initialize 'custom-initialize-default
  :type 'boolean
  :group 'menu)

(defvar-local list-buffers-directory nil
  "String to display in buffer listings for buffers not visiting a file.")

(defun menu-bar-select-buffer ()
  (declare (obsolete nil "28.1"))
  (interactive)
  (switch-to-buffer last-command-event))

(defun menu-bar-select-frame (frame)
  (make-frame-visible frame)
  (raise-frame frame)
  (select-frame frame))

(defun menu-bar-update-buffers-1 (elt)
  (let* ((buf (car elt))
	 (file
	  (and (if (eq buffers-menu-show-directories 'unless-uniquify)
		   (or (not (boundp 'uniquify-buffer-name-style))
		       (null uniquify-buffer-name-style))
		 buffers-menu-show-directories)
	       (or (buffer-file-name buf)
		   (buffer-local-value 'list-buffers-directory buf)))))
    (when file
      (setq file (file-name-directory file)))
    (when (and file (> (length file) 20))
      (setq file (concat "..." (substring file -17))))
    (cons (if buffers-menu-show-status
	      (let ((mod (if (buffer-modified-p buf) "*" ""))
		    (ro (if (buffer-local-value 'buffer-read-only buf) "%" "")))
		(if file
		    (format "%s  %s%s  --  %s" (cdr elt) mod ro file)
		  (format "%s  %s%s" (cdr elt) mod ro)))
	    (if file
		(format "%s  --  %s"  (cdr elt) file)
	      (cdr elt)))
	  buf)))

(defvar menu-bar-buffers-menu-command-entries
  (list '(command-separator "--")
	(list 'next-buffer
	      'menu-item
	      "Next Buffer"
	      'next-buffer
	      :help "Switch to the \"next\" buffer in a cyclic order")
	(list 'previous-buffer
	      'menu-item
	      "Previous Buffer"
	      'previous-buffer
	      :help "Switch to the \"previous\" buffer in a cyclic order")
	(list 'select-named-buffer
	      'menu-item
	      "Select Named Buffer..."
	      'switch-to-buffer
	      :help "Prompt for a buffer name, and select that buffer in the current window")
	(list 'list-all-buffers
	      'menu-item
	      "List All Buffers"
	      'list-buffers
	      :help "Pop up a window listing all Emacs buffers")
	(list 'select-buffer-in-project
	      'menu-item
	      "Select Buffer In Project..."
	      'project-switch-to-buffer
	      :help "Prompt for a buffer belonging to current project, and switch to it")
	(list 'list-buffers-in-project
	      'menu-item
	      "List Buffers In Project..."
	      'project-list-buffers
	      :help "Pop up a window listing all Emacs buffers belonging to current project"))
  "Entries to be included at the end of the \"Buffers\" menu.")

(defvar menu-bar-select-buffer-function 'switch-to-buffer
  "Function to select the buffer chosen from the `Buffers' menu-bar menu.
It must accept a buffer as its only required argument.")

(defun menu-bar-buffer-vector (alist)
  "Turn ((name . buffer) ...) into a menu."
  (let ((buffers-vec (make-vector (length alist) nil))
        (i (length alist)))
    (dolist (pair alist)
      (setq i (1- i))
      (aset buffers-vec i
            (cons (car pair)
                  (let ((buf (cdr pair)))
                    (lambda ()
                      (interactive)
                      (funcall menu-bar-select-buffer-function buf))))))
    buffers-vec))

(defun menu-bar-update-buffers (&optional force)
  "If user discards the Buffers item, play along."
  (and (lookup-key (current-global-map) [menu-bar buffer])
       (or force (frame-or-buffer-changed-p))
       (let ((buffers (buffer-list))
	     frames buffers-menu)
         ;; Ignore the initial frame if present.  It can happen if
         ;; Emacs was started as a daemon.  (bug#53740)
         (dolist (frame (frame-list))
           (unless (equal (terminal-name (frame-terminal frame))
                          "initial_terminal")
             (push frame frames)))
	 ;; Make the menu of buffers proper.
	 (setq buffers-menu
               (let ((i 0)
		     (limit (and (integerp buffers-menu-max-size)
				 (> buffers-menu-max-size 1)
				 buffers-menu-max-size))
                     alist)
		 ;; Put into each element of buffer-list
		 ;; the name for actual display,
		 ;; perhaps truncated in the middle.
                 (while buffers
                   (let* ((buf (pop buffers))
                          (name (buffer-name buf)))
                     (unless (eq ?\s (aref name 0))
                       (push (menu-bar-update-buffers-1
                              (cons buf
				    (if (and (integerp buffers-menu-buffer-name-length)
					     (> (length name) buffers-menu-buffer-name-length))
					(concat
					 (substring
					  name 0 (/ buffers-menu-buffer-name-length 2))
					 "..."
					 (substring
					  name (- (/ buffers-menu-buffer-name-length 2))))
				      name)
                                    ))
                             alist)
                       ;; If requested, list only the N most recently
                       ;; selected buffers.
                       (when (eql limit (setq i (1+ i)))
                         (setq buffers nil)))))
		 (list (menu-bar-buffer-vector alist))))

	 ;; Make a Frames menu if we have more than one frame.
	 (when (cdr frames)
	   (let* ((frames-vec (make-vector (length frames) nil))
                  (frames-menu
                   (cons 'keymap
                         (list "Select Frame" frames-vec)))
                  (i 0))
             (dolist (frame frames)
               (aset frames-vec i
                     (cons
                      (frame-parameter frame 'name)
                      (lambda ()
                        (interactive) (menu-bar-select-frame frame))))
               (setq i (1+ i)))
	     ;; Put it after the normal buffers
	     (setq buffers-menu
		   (nconc buffers-menu
			  `((frames-separator "--")
			    (frames menu-item "Frames" ,frames-menu))))))

	 ;; Add in some normal commands at the end of the menu.
	 (setq buffers-menu
	       (nconc buffers-menu menu-bar-buffers-menu-command-entries))

         ;; We used to "(define-key (current-global-map) [menu-bar buffer]"
         ;; but that did not do the right thing when the [menu-bar buffer]
         ;; entry above had been moved (e.g. to a parent keymap).
	 (setcdr global-buffers-menu-map (cons "Buffers" buffers-menu)))))

(add-hook 'menu-bar-update-hook 'menu-bar-update-buffers)

(menu-bar-update-buffers)

;; this version is too slow
;;(defun format-buffers-menu-line (buffer)
;;  "Returns a string to represent the given buffer in the Buffer menu.
;;nil means the buffer shouldn't be listed.  You can redefine this."
;;  (if (string-match "\\` " (buffer-name buffer))
;;      nil
;;    (with-current-buffer buffer
;;     (let ((size (buffer-size)))
;;       (format "%s%s %-19s %6s %-15s %s"
;;	       (if (buffer-modified-p) "*" " ")
;;	       (if buffer-read-only "%" " ")
;;	       (buffer-name)
;;	       size
;;	       mode-name
;;	       (or (buffer-file-name) ""))))))

;;; Set up a menu bar menu for the minibuffer.

(dolist (map (list minibuffer-local-map
		   ;; This shouldn't be necessary, but there's a funny
		   ;; bug in keymap.c that I don't understand yet.  -stef
		   minibuffer-local-completion-map))
  (define-key map [menu-bar minibuf]
    (cons "Minibuf" (make-sparse-keymap "Minibuf"))))

(let ((map minibuffer-local-completion-map))
  (define-key map [menu-bar minibuf ?\?]
    '(menu-item "List Completions" minibuffer-completion-help
		:help "Display all possible completions"))
  (define-key map [menu-bar minibuf space]
    '(menu-item "Complete Word" minibuffer-complete-word
		:help "Complete at most one word"))
  (define-key map [menu-bar minibuf tab]
    '(menu-item "Complete" minibuffer-complete
		:help "Complete as far as possible")))

(let ((map minibuffer-local-map))
  (define-key map [menu-bar minibuf quit]
    '(menu-item "Quit" abort-recursive-edit
		:help "Abort input and exit minibuffer"))
  (define-key map [menu-bar minibuf return]
    '(menu-item "Enter" exit-minibuffer
		:key-sequence "\r"
		:help "Terminate input and exit minibuffer"))
  (define-key map [menu-bar minibuf isearch-forward]
    '(menu-item "Isearch History Forward" isearch-forward
		:help "Incrementally search minibuffer history forward"))
  (define-key map [menu-bar minibuf isearch-backward]
    '(menu-item "Isearch History Backward" isearch-backward
		:help "Incrementally search minibuffer history backward"))
  (define-key map [menu-bar minibuf next]
    '(menu-item "Next History Item" next-history-element
		:help "Put next minibuffer history element in the minibuffer"))
  (define-key map [menu-bar minibuf previous]
    '(menu-item "Previous History Item" previous-history-element
		:help "Put previous minibuffer history element in the minibuffer")))

(define-minor-mode menu-bar-mode
  "Toggle display of a menu bar on each frame (Menu Bar mode).

This command applies to all frames that exist and frames to be
created in the future."
  :init-value t
  :global t
  ;; It's defined in C/cus-start, this stops the d-m-m macro defining it again.
  :variable menu-bar-mode

  ;; Turn the menu-bars on all frames on or off.
  (let ((val (if menu-bar-mode 1 0)))
    (dolist (frame (frame-list))
      (set-frame-parameter frame 'menu-bar-lines val))
    ;; If the user has given `default-frame-alist' a `menu-bar-lines'
    ;; parameter, replace it.
    (if (assq 'menu-bar-lines default-frame-alist)
	(setq default-frame-alist
	      (cons (cons 'menu-bar-lines val)
		    (assq-delete-all 'menu-bar-lines
				     default-frame-alist)))))
  ;; Make the message appear when Emacs is idle.  We can not call message
  ;; directly.  The minor-mode message "Menu Bar mode disabled" comes
  ;; after this function returns, overwriting any message we do here.
  (when (and (called-interactively-p 'interactive) (not menu-bar-mode))
    (run-with-idle-timer 0 nil 'message
                         (substitute-command-keys
                          "Menu Bar mode disabled.  \
Use \\[menu-bar-mode] to make the menu bar appear."))))

;;;###autoload
;; (This does not work right unless it comes after the above definition.)
;; This comment is taken from tool-bar.el near
;; (put 'tool-bar-mode ...)
;; We want to pretend the menu bar by standard is on, as this will make
;; customize consider disabling the menu bar a customization, and save
;; that.  We could do this for real by setting :init-value above, but
;; that would overwrite disabling the menu bar from X resources.
(put 'menu-bar-mode 'standard-value '(t))

(defun toggle-menu-bar-mode-from-frame (&optional arg)
  "Toggle display of the menu bar.
See `menu-bar-mode' for more information."
  (interactive (list (or current-prefix-arg 'toggle)))
  (if (eq arg 'toggle)
      (menu-bar-mode
       (if (menu-bar-positive-p
	    (frame-parameter (menu-bar-frame-for-menubar) 'menu-bar-lines))
	    0 1))
    (menu-bar-mode arg)))

(declare-function x-menu-bar-open "term/x-win" (&optional frame))
(declare-function w32-menu-bar-open "term/w32-win" (&optional frame))
(declare-function pgtk-menu-bar-open "term/pgtk-win" (&optional frame))
(declare-function haiku-menu-bar-open "haikumenu.c" (&optional frame))

(defun lookup-key-ignore-too-long (map key)
  "Call `lookup-key' and convert numeric values to nil."
  (let ((binding (lookup-key map key)))
    (if (numberp binding)       ; `too long'
        nil
      binding)))

(defun popup-menu (menu &optional position prefix from-menu-bar)
  "Popup MENU and call the selected option.
MENU can be a keymap, an easymenu-style menu or a list of keymaps as for
`x-popup-menu'.
The menu is shown at the location specified by POSITION, which
defaults to the place of the mouse click that popped the menu.
For the form of POSITION, see `popup-menu-normalize-position'.
PREFIX is the prefix argument (if any) to pass to the command.
FROM-MENU-BAR, if non-nil, means we are dropping one of menu-bar's menus."
  (let* ((map (cond
	       ((keymapp menu) menu)
	       ((and (listp menu) (keymapp (car menu))) menu)
               ((not (listp menu)) nil)
	       (t (let* ((map (easy-menu-create-menu (car menu) (cdr menu)))
			 (filter (when (symbolp map)
				   (plist-get (get map 'menu-prop) :filter))))
		    (if filter (funcall filter (symbol-function map)) map)))))
	 (selected-frame (selected-frame))
	 (frame (if (and (eq (framep selected-frame) t) (frame-parent)
			 from-menu-bar
			 (zerop (or (frame-parameter nil 'menu-bar-lines) 0)))
		    ;; If the selected frame is a tty child frame
		    ;; without its own menu bar and we are called from
		    ;; the menu bar, the menu bar must be on the root
		    ;; frame of the selected frame.
		    (frame-root-frame)
		  (selected-frame)))
	 event cmd)
    (with-selected-frame frame
      (if from-menu-bar
	  (let* ((xy (posn-x-y position))
		 (menu-symbol (menu-bar-menu-at-x-y (car xy) (cdr xy))))
	    (setq position (list menu-symbol (list frame '(menu-bar)
						   xy 0))))
	(setq position (popup-menu-normalize-position position)))

      ;; The looping behavior was taken from lmenu's popup-menu-popup
      (while (and map (setq event
			    ;; map could be a prefix key, in which case
			    ;; we need to get its function cell
			    ;; definition.
			    (x-popup-menu position (indirect-function map))))
	;; Strangely x-popup-menu returns a list.
	;; mouse-major-mode-menu was using a weird:
	;; (key-binding (apply 'vector (append '(menu-bar) menu-prefix events)))
	(setq cmd
	      (cond
	       ((and from-menu-bar
		     (consp event)
		     (numberp (car event))
		     (numberp (cdr event)))
		(let ((x (car event))
		      (y (cdr event))
		      menu-symbol)
		  (setq menu-symbol (menu-bar-menu-at-x-y x y))
		  (setq position (list menu-symbol (list frame '(menu-bar)
							 event 0)))
		  (if (not (eq frame selected-frame))
		      ;; If we are using the menu bar from the root
		      ;; frame, look up the key binding in the keymaps
		      ;; of the initially selected window's buffer to
		      ;; make sure that navigating the menu bar with the
		      ;; keyboard works as intended.
		      (setq map
			    (key-binding (vector 'menu-bar menu-symbol) nil nil
					 (frame-selected-window selected-frame)))
		    (setq map
			  (key-binding (vector 'menu-bar menu-symbol))))))
	       ((and (not (keymapp map)) (listp map))
		;; We were given a list of keymaps.  Search them all
		;; in sequence until a first binding is found.
		(let ((mouse-click (apply 'vector event))
		      binding)
		  (while (and map (null binding))
		    (setq binding (lookup-key-ignore-too-long (car map) mouse-click))
		    (setq map (cdr map)))
		  binding))
	       (t
		;; We were given a single keymap.
		(lookup-key map (apply 'vector event)))))
	;; Clear out echoing, which perhaps shows a prefix arg.
	(message "")
	;; Maybe try again but with the submap.
	(setq map (if (keymapp cmd) cmd))))

    ;; If the user did not cancel by refusing to select,
    ;; and if the result is a command, run it.
    (when (and (null map) (commandp cmd))
      (setq prefix-arg prefix)
      ;; `setup-specified-language-environment', for instance,
      ;; expects this to be set from a menu keymap.
      (setq last-command-event (car (last event)))
      (setq from--tty-menu-p nil)
      ;; Signal use-dialog-box-p this command was invoked from a menu.
      (let ((from--tty-menu-p t))
        ;; mouse-major-mode-menu was using `command-execute' instead.
        (call-interactively cmd)))))

(defun popup-menu-normalize-position (position)
  "Convert the POSITION to the form which `popup-menu' expects internally.
POSITION can be an event, a posn- value, a value having the
form ((XOFFSET YOFFSET) WINDOW), or nil.
If nil, the current mouse position is used, or nil if there is no mouse."
  (cond
    ;; nil -> mouse cursor position
    ((eq position nil)
     (let ((mp (mouse-pixel-position)))
       (list (list (cadr mp) (cddr mp)) (car mp))))
    ;; Value returned from `event-end' or `posn-at-point'.
    ((posnp position)
     (let ((xy (posn-x-y position)))
       (list (list (car xy) (cdr xy))
	     (posn-window position))))
    ;; `touchscreen-begin' or `touchscreen-end' event.
    ((or (eq (car-safe position) 'touchscreen-begin)
         (eq (car-safe position) 'touchscreen-end))
     position)
    ;; Event.
    ((eventp position)
     (popup-menu-normalize-position (event-end position)))
    ;; Some other value.
    (t position)))

(defcustom tty-menu-open-use-tmm nil
  "If non-nil, \\[menu-bar-open] on a TTY will invoke `tmm-menubar'.

If nil, \\[menu-bar-open] will drop down the menu corresponding to the
first (leftmost) menu-bar item; you can select other items by typing
\\[forward-char], \\[backward-char], \\[right-char] and \\[left-char]."
  :type '(choice (const :tag "F10 drops down TTY menus" nil)
		 (const :tag "F10 invokes tmm-menubar" t))
  :group 'display
  :version "24.4")

(defvar tty-menu--initial-menu-x 1
  "X coordinate of the first menu-bar menu dropped by F10.

This is meant to be used only for debugging TTY menus.")

(defun menu-bar-open (&optional frame initial-x)
  "Start key navigation of the menu bar in FRAME.

Optional argument INITIAL-X gives the X coordinate of the
first TTY menu-bar menu to be dropped down.  Interactively,
this is the numeric argument to the command.
This function decides which method to use to access the menu
depending on FRAME's terminal device.  On X displays, it calls
`x-menu-bar-open'; on Windows, `w32-menu-bar-open'; on Haiku,
`haiku-menu-bar-open'; otherwise it calls either `popup-menu'
or `tmm-menubar' depending on whether `tty-menu-open-use-tmm'
is nil or not.

If FRAME is nil or not given, use the selected frame."
  (interactive
   (list nil (prefix-numeric-value current-prefix-arg)))
  (let* ((type (framep (or frame (selected-frame))))
	 root
	 (frame (if (and (eq type t) (frame-parent frame)
			 (null tty-menu-open-use-tmm)
			 (zerop (or (frame-parameter frame 'menu-bar-lines) 0))
			 (setq root (frame-root-frame))
			 (not (zerop
			       (or (frame-parameter root 'menu-bar-lines) 0))))
		    ;; If FRAME is a tty child frame without its own
		    ;; menu bar, 'tty-menu-open-use-tmm' is false and
		    ;; FRAME's root frame has a menu bar, use that root
		    ;; frame's menu bar.
		    root
		  frame)))
    (cond
     ((eq type 'x) (x-menu-bar-open frame))
     ((eq type 'w32) (w32-menu-bar-open frame))
     ((eq type 'haiku) (haiku-menu-bar-open frame))
     ((eq type 'pgtk) (pgtk-menu-bar-open frame))
     ((and (null tty-menu-open-use-tmm)
	   (not (zerop (or (frame-parameter frame 'menu-bar-lines) 0))))
      ;; Make sure the menu bar is up to date.  One situation where
      ;; this is important is when this function is invoked by name
      ;; via M-x, in which case the menu bar includes the "Minibuf"
      ;; menu item that should be removed when we exit the minibuffer.
      (force-mode-line-update)
      (redisplay)
      (let* ((x (max initial-x tty-menu--initial-menu-x))
	     (menu (menu-bar-menu-at-x-y x 0 frame)))
	(popup-menu (or
		     (lookup-key-ignore-too-long
                      global-map (vector 'menu-bar menu))
		     (lookup-key-ignore-too-long
                      (current-local-map) (vector 'menu-bar menu))
		     (cdar (minor-mode-key-binding (vector 'menu-bar menu)))
                     (mouse-menu-bar-map))
		    (posn-at-x-y x 0 frame t) nil t)))
     (t (with-selected-frame (or frame (selected-frame))
          (tmm-menubar))))))

(global-set-key [f10] 'menu-bar-open)

(defun menu-bar-open-mouse (event)
  "Open the menu bar for the menu item clicked on by the mouse.
EVENT should be a mouse down or click event.

Also see `menu-bar-open', which this calls.
This command is to be used when you click the mouse in the menubar."
  (interactive "e")
  ;; This only should be bound to clicks on the menu-bar, outside of
  ;; any window.
  (let ((window (posn-window (event-start event))))
    (when window
      (error "Event is inside window %s" window)))

  (let* ((x-position (car (posn-x-y (event-start event))))
         (menu-bar-item-cons (menu-bar-item-at-x x-position)))
    (menu-bar-open nil
                   (if menu-bar-item-cons
                       (cdr menu-bar-item-cons)
                     0))))

(defun menu-bar-keymap (&optional keymap)
  "Return the current menu-bar keymap.
The ordering of the return value respects `menu-bar-final-items'.

It's possible to use the KEYMAP argument to override the default keymap
that is the currently active maps.  For example, the argument KEYMAP
could provide `global-map' where items are limited to the global map only."
  (let ((menu-bar '())
        (menu-end '()))
    (map-keymap
     (lambda (key binding)
       (let ((pos (seq-position menu-bar-final-items key))
             (menu-item (cons key binding)))
         (if pos
             ;; If KEY is the name of an item that we want to put
             ;; last, store it separately with explicit ordering for
             ;; sorting.
             (push (cons pos menu-item) menu-end)
           (push menu-item menu-bar))))
     (or keymap (lookup-key (menu-bar-current-active-maps) [menu-bar])))
    `(keymap ,@(nreverse menu-bar)
             ,@(mapcar #'cdr (sort menu-end
                                   (lambda (a b)
                                     (< (car a) (car b))))))))

(defun menu-bar-current-active-maps ()
  "Return the current active maps in the order the menu bar displays them.
This value does not take into account `menu-bar-final-items' as that applies
per-item."
  ;; current-active-maps returns maps in the order local then
  ;; global. The menu bar displays items in the opposite order.
  (cons 'keymap (nreverse (current-active-maps))))

(defun menu-bar-item-at-x (x-position)
  "Return a cons of the form (KEY . X) for a menu item.
The returned X is the left X coordinate for that menu item.

X-POSITION is the X coordinate being queried.  If nothing is clicked on,
returns nil."
  (let ((column 0)
        (menu-bar (menu-bar-keymap))
        prev-key
        prev-column
        keys-seen
        found)
    (catch 'done
      (map-keymap
       (lambda (key binding)
         (unless (memq key keys-seen)
           (push key keys-seen)
           (when (> column x-position)
             (setq found t)
             (throw 'done nil))
           (setq prev-key key)
           (pcase binding
             ((or `(,(and (pred stringp) name) . ,_) ;Simple menu item.
                  `(menu-item ,name ,_cmd            ;Extended menu item.
                              . ,(and props
                                      (guard (let ((visible
                                                    (plist-get props :visible)))
                                               (or (null visible)
                                                   (eval visible)))))))
              (setq prev-column column
                    column (+ column (length name) 1))))))
       menu-bar)
      ;; Check the last menu item.
      (when (> column x-position)
        (setq found t)))
    (if found
        (cons prev-key prev-column)
      nil)))

(defun buffer-menu-open ()
  "Start key navigation of the buffer menu.
This is the keyboard interface to \\[mouse-buffer-menu]."
  (interactive)
  (popup-menu (mouse-buffer-menu-keymap)
              (posn-at-x-y 0 0 nil t)))

(global-set-key [C-f10] 'buffer-menu-open)

(defun mouse-buffer-menu-keymap ()
  (let* ((menu (mouse-buffer-menu-map))
         (km (make-sparse-keymap (pop menu))))
    (dolist (item (nreverse menu))
      (let* ((name (pop item)))
        (define-key km (vector (intern name))
          (list name 'keymap name
                (menu-bar-buffer-vector item)))))
    km))

(defun menu-bar-define-mouse-key (map key def)
  "Like `define-key', but add all possible prefixes for the mouse."
  (define-key map (vector key) def)
  (mapc (lambda (prefix) (define-key map (vector prefix key) def))
        ;; This list only needs to contain special window areas that
        ;; are rendered in TTYs.  No need for *-scroll-bar, *-fringe,
        ;; or *-divider.
        '(tab-line header-line menu-bar tab-bar mode-line vertical-line
          left-margin right-margin)))

(defvar tty-menu-navigation-map
  (let ((map (make-sparse-keymap)))
    ;; The next line is disabled because it breaks interpretation of
    ;; escape sequences, produced by TTY arrow keys, as tty-menu-*
    ;; commands.  Instead, we explicitly bind some keys to
    ;; tty-menu-exit.
    ;;(define-key map [t] 'tty-menu-exit)

    ;; The tty-menu-* are just symbols interpreted by term.c, they are
    ;; not real commands.
    (dolist (bind '((keyboard-quit . tty-menu-exit)
                    (keyboard-escape-quit . tty-menu-exit)
                    ;; The following two will need to be revised if we ever
                    ;; support a right-to-left menu bar.
                    (forward-char . tty-menu-next-menu)
                    (backward-char . tty-menu-prev-menu)
                    (right-char . tty-menu-next-menu)
                    (left-char . tty-menu-prev-menu)
                    (next-line . tty-menu-next-item)
                    (previous-line . tty-menu-prev-item)
                    (newline . tty-menu-select)
                    (newline-and-indent . tty-menu-select)
		    (menu-bar-open . tty-menu-exit)))
      (substitute-key-definition (car bind) (cdr bind)
                                 map (current-global-map)))

    ;; The bindings of menu-bar items are so that clicking on the menu
    ;; bar when a menu is already shown pops down that menu.
    (define-key map [menu-bar t] 'tty-menu-exit)

    (define-key map [?\C-r] 'tty-menu-select)
    (define-key map [?\C-j] 'tty-menu-select)
    (define-key map [return] 'tty-menu-select)
    (define-key map [linefeed] 'tty-menu-select)
    (menu-bar-define-mouse-key map 'mouse-1 'tty-menu-select)
    (menu-bar-define-mouse-key map 'drag-mouse-1 'tty-menu-select)
    (menu-bar-define-mouse-key map 'mouse-2 'tty-menu-select)
    (menu-bar-define-mouse-key map 'drag-mouse-2 'tty-menu-select)
    (menu-bar-define-mouse-key map 'mouse-3 'tty-menu-select)
    (menu-bar-define-mouse-key map 'drag-mouse-3 'tty-menu-select)
    (menu-bar-define-mouse-key map 'wheel-down 'tty-menu-next-item)
    (menu-bar-define-mouse-key map 'wheel-up 'tty-menu-prev-item)
    (menu-bar-define-mouse-key map 'wheel-left 'tty-menu-prev-menu)
    (menu-bar-define-mouse-key map 'wheel-right 'tty-menu-next-menu)
    ;; The following 6 bindings are for those whose text-mode mouse
    ;; lack the wheel.
    (menu-bar-define-mouse-key map 'S-mouse-1 'tty-menu-next-item)
    (menu-bar-define-mouse-key map 'S-drag-mouse-1 'tty-menu-next-item)
    (menu-bar-define-mouse-key map 'S-mouse-2 'tty-menu-prev-item)
    (menu-bar-define-mouse-key map 'S-drag-mouse-2 'tty-menu-prev-item)
    (menu-bar-define-mouse-key map 'S-mouse-3 'tty-menu-prev-item)
    (menu-bar-define-mouse-key map 'S-drag-mouse-3 'tty-menu-prev-item)
    ;; The down-mouse events must be bound to tty-menu-ignore, so that
    ;; only releasing the mouse button pops up the menu.
    (menu-bar-define-mouse-key map 'down-mouse-1 'tty-menu-ignore)
    (menu-bar-define-mouse-key map 'down-mouse-2 'tty-menu-ignore)
    (menu-bar-define-mouse-key map 'down-mouse-3 'tty-menu-ignore)
    (menu-bar-define-mouse-key map 'C-down-mouse-1 'tty-menu-ignore)
    (menu-bar-define-mouse-key map 'C-down-mouse-2 'tty-menu-ignore)
    (menu-bar-define-mouse-key map 'C-down-mouse-3 'tty-menu-ignore)
    (menu-bar-define-mouse-key map 'mouse-movement 'tty-menu-mouse-movement)
    map)
  "Keymap used while processing TTY menus.")

(provide 'menu-bar)

;;; menu-bar.el ends here
