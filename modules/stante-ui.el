;;; prelude-ui.el --- Stante Pede Modules: User interface configuration
;;; -*- coding: utf-8; lexical-binding: t -*-
;;
;; Copyright (c) 2012 Sebastian Wiesner
;;
;; Author: Sebastian Wiesner <lunaryorn@gmail.com>
;; URL: https://github.com/lunaryorn/stantepede.git
;; Version: 1.0.0
;; Keywords: convenience frames tools

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free Software
;; Foundation; either version 3 of the License, or (at your option) any later
;; version.

;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
;; FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
;; details.

;; You should have received a copy of the GNU General Public License along with
;; GNU Emacs; see the file COPYING.  If not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
;; USA.


;;; Commentary:

;; Improve the general user interface of Emacs.

;; Default fonts
;; -------------
;;
;; Set the default font.
;;
;; On OS X, use Menlo 13pt.
;;
;; On Windows, use Consolas 10pt, matching the Visual Studio defaults.  Consolas
;; is not available by default, but comes with many Microsoft programs,
;; including Visual Studio, Office, and others.
;;
;; On all other systems, use Dejavu Sans Mono 10pt.  This font is used as
;; standard monospace font on many Linux distributions, hence seems a good
;; choice for Stante Pede, too.

;; Noise reduction
;; ---------------
;;
;; Reduce the user interface noise of Emacs.
;;
;; Disable the tool bar, the menu bar (except on OS X where the menu bar is
;; always present), the startup screen, the blinking cursor and the alarm beeps.
;; Simplify Yes/No questions to y/n, and reduce frame fringes to occupy less
;; screen space.

;; More information
;; ----------------
;;
;; Add more information to the user interface.
;;
;; Set a reasonable frame title and configure the mode line to show the current
;; line and column number, as well as an indication of the size of the current
;; buffer.
;;
;; Uniquify buffer names in case of naming collisions.

;; Completion
;; ----------
;;
;; Enable completion via ido – interactive do – for buffer switching and file
;; visiting.  Enable icomplete mode to improve minibuffer completion.

;; Initial frame position and size
;; -------------------------------
;;
;; Save the position and size of the current frame when killing Emacs and apply
;; these saved parameters to the initial frame.  If Emacs is with a single
;; frame, effectively remembers the frame position and size like other GUI
;; applications.

;; Key bindings
;; ------------
;;
;; C-x C-b shows IBuffer (see  `ibuffer').  Replaces the standard `buffer-menu'.
;;
;; C-x p shows a list of running processes similar to the Unix command line
;; utility "top".
;;
;; C-h A searches for any Lisp symbol matching a regular expression (see
;; `apropos').


;;; Code:

(require 'stante-autoloads)

;; Disable toolbar and menu bar (except on OS X where the menubar is present
;; anyway)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(unless (stante-is-os-x)
  (when (fboundp 'menu-bar-mode)
    (menu-bar-mode -1)))

;; Disable blinking cursor
(blink-cursor-mode -1)

;; Disable alarm beeps
(setq ring-bell-function 'ignore)

;; Disable startup screen
(setq inhibit-startup-screen t)

;; Smoother scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;; Improve mode line
(line-number-mode t)
(column-number-mode t)
(size-indication-mode t)

;; Reduce fringes
(if (fboundp 'fringe-mode)
    (fringe-mode 4))

;; Unify Yes/No questions
(fset 'yes-or-no-p 'y-or-n-p)

;; Show file name or buffer name in frame title
(setq frame-title-format
      '(:eval (if (buffer-file-name)
                  (abbreviate-file-name (buffer-file-name)) "%b")))

;; De-duplicate buffer names
(require 'uniquify)
(eval-after-load 'uniquify
  #'(setq uniquify-buffer-name-style 'forward
          uniquify-separator "/"
          ;; Re-uniquify after killing buffers
          uniquify-after-kill-buffer-p t
          ;; Ignore special buffers
          uniquify-ignore-buffers-re "^\\*"))

;; Improve completion for file and buffer names
(ido-mode t)
(eval-after-load 'ido
  #'(setq
     ;; Match characters if string doesn't match
     ido-enable-flex-matching t
     ;; Create a new buffer if absolutely nothing matches
     ido-create-new-buffer 'always
     ;; Start with filename at point if any can be guessed
     ido-use-filename-at-point 'guess
     ;; Remember ido state
     ido-save-directory-list-file (concat stante-var-dir "ido.hist")
     ;; When opening a new file, do so in the previously selected window
     ido-default-file-method 'selected-window))
;; Move summary and "output" (i.e. from Auctex) to the end to keep these out of
;; the way
(add-hook 'ido-make-buffer-list-hook 'ido-summary-buffers-to-end)

;; Improve minibuffer completion
(icomplete-mode +1)

;; Move between windows with Shift + Arrows
(require 'windmove)
(eval-after-load 'windmove
  #'(windmove-default-keybindings))

;; Default font
(cond
 ((stante-is-os-x)
  ;; OS X default font, but larger font size
  (set-face-attribute 'default nil :family "Menlo" :height 130))
 ((stante-is-windows)
  ;; Visual Studio defaults
  (set-face-attribute 'default nil :family "Consolas" :height 10))
 (t
  ;; A reasonable choice for all other systems
  (set-face-attribute 'default nil :family "Dejavu Sans Mono" :height 100))
 )

;; Reuse current frame for EDiff
(eval-after-load 'ediff-wind
  #'(setq ediff-window-setup-function 'ediff-setup-windows-plain))

;; Theme support
(defvar stante-known-themes-alist
  ;;
  '((birds-of-paradise-plus . birds-of-paradise-plus-theme)
    (inkpot . inkpot-theme)
    (ir-black . ir-black-theme)
    (molokai . molokai-theme)
    (pastels-on-dark . pastels-on-dark-theme)
    (solarized-light . color-theme-solarized)
    (solarized-dark . color-theme-solarized)
    (tango-2 . tango-2-theme)
    (twilight-anti-bright . twilight-anti-bright-theme)
    (twilight-bright . twilight-bright-theme)
    (twilight . twilight-theme)
    (zen-and-art . zen-and-art-theme)
    (zenburn . zenburn-theme))
  "Color themes know to stante.

Maps the theme name to the package that contains this theme.
This is is naturally incomplete.  Feel free to extend, and please
report color themes not contained in this list to
https://github.com/lunaryorn/stante-pede/issues.")

(defadvice load-theme (before load-theme-install-package)
  "Install the theme package before loading the theme.

See `stante-known-themes-alist' for a list of known theme names and
corresponding packages."
  (let* ((theme (ad-get-arg 0))
         (package (cdr (assoc theme stante-known-themes-alist))))
    (when package
      (message "Installing package %s for theme %s." package theme)
      (package-install-if-needed package))))
(ad-activate 'load-theme t)

(defvar stante-save-frame-parameters-file
  (concat stante-var-dir "frame-parameters")
  "File in which to storce frame parameters on exit.")

(defun stante-restore-frame-parameters ()
  "Restore the frame parameters of the initial frame."
  (condition-case nil
      (let* ((contents (stante-get-file-contents
                        stante-save-frame-parameters-file))
             (parts (split-string (stante-string-trim contents) "x"))
             (params (mapcar 'string-to-number parts)))
        (setq initial-frame-alist
              (stante-merge-alists initial-frame-alist
                                   `((left . ,(nth 0 params))
                                     (top . ,(nth 1 params))
                                     (width . ,(max (nth 2 params) 80))
                                     (height . ,(max (nth 3 params) 35))))))
    (error nil)))

(defun stante-save-frame-parameters ()
  "Save frame parameters of the selected frame.

Save the top left position and the width and height to
`stante-save-frame-parameters-file'."
  (condition-case nil
      (let ((frame (selected-frame)))
        (when (and frame (display-graphic-p frame)) ; GUI frames only!
          (let ((params (format "%sx%sx%sx%s\n"
                                (frame-parameter frame 'left)
                                (frame-parameter frame 'top)
                                (frame-parameter frame 'width)
                                (frame-parameter frame 'height))))
            (stante-set-file-contents stante-save-frame-parameters-file params)
            t)))
    (file-error nil)))
(unless noninteractive
       (add-hook 'after-init-hook 'stante-restore-frame-parameters)
       (add-hook 'kill-emacs-hook 'stante-save-frame-parameters))

;; Key bindings
(global-set-key (kbd "C-x C-b") 'ibuffer)
;; Similar to C-x d
(global-set-key (kbd "C-x p") 'proced)
;; Complementary to C-h a
(global-set-key (kbd "C-h A") 'apropos)

(provide 'stante-ui)

;;; stante-ui.el ends here
