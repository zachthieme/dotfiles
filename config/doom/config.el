(setq user-full-name "Zach Thieme"
      user-mail-address "zach@techsage.org")

(setq doom-theme 'doom-one)
(setq display-line-numbers-type `relative)

(defun my/org-insert-shared-link ()
  "Prompt for a URL and friendly name, add it to links.org with a :link: tag and timestamp, and insert a raw link in the current buffer."
  (interactive)
  (let* ((url (read-string "URL: "))
         (desc (read-string "Friendly name: "))
         (date (format-time-string "%Y-%m-%d"))
         (links-file (expand-file-name "~/Library/Mobile Documents/com~apple~CloudDocs/org/links.org"))
         (entry (format "* %s :link:\n%s\nAdded: %s\n\n"
                        desc
                        (format "[[%s][%s]]" url desc)
                        date)))
    ;; Append to links.org
    (with-current-buffer (find-file-noselect links-file)
      (goto-char (point-max))
      (insert entry)
      (save-buffer))
    ;; Insert direct link into current buffer
    (insert (format "[[%s][%s]]" url desc))))


;; Enable visual-line-mode (soft wrap) in agenda views, including tag searches
(add-hook! 'org-agenda-mode-hook
  (visual-line-mode 1)
  (adaptive-wrap-prefix-mode 1)) ;; Optional, better-looking wraps

 ; ensure that TODO log completion date
(setq org-log-done 'time)
(setq org-log-into-drawer t)

; ignore dashboard on startup
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(setq doom-fallback-buffer-name "scratch")
(setq +doom-dashboard-functions '())

; open daily note on emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (org-roam-dailies-goto-today)))

; (setq org-roam-dailies-directory "daily/")  ;; relative to `org-roam-directory`

(setq org-roam-dailies-capture-templates
      '(("d" "default" entry
         "* %?"
         :target (file+head "%<%Y-%m-%d>.org"
                            "#+title: %<%Y-%m-%d>\n* %<%A %B %e, %Y>\n** Meetings\n***\n** Notes\n***\n")
         :empty-lines 1)))

(setq org-directory "~/Library/Mobile Documents/com~apple~CloudDocs/org/")

(setq org-agenda-files 

   (directory-files-recursively "~/Library/Mobile Documents/com~apple~CloudDocs/org" "\\.org$"))

(use-package! org-roam
  :ensure t
  :demand t  ;; Ensure org-roam is loaded by default
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/Library/Mobile Documents/com~apple~CloudDocs/org/RoamNotes")
  (org-roam-completion-everywhere t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n I" . org-roam-node-insert-immediate)
         ("C-c n p" . my/org-roam-find-project)
         ("C-c n t" . my/org-roam-capture-task)
         ("C-c n b" . my/org-roam-capture-inbox)
         :map org-mode-map
         ("C-M-i" . completion-at-point)
         :map org-roam-dailies-map
         ("Y" . org-roam-dailies-capture-yesterday)
         ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies) ;; Ensure the keymap is available
  (org-roam-db-autosync-mode))


(defun org-roam-node-insert-immediate (arg &rest args)
  (interactive "P")
  (let ((args (push arg args))
        (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

(defun my/org-roam-filter-by-tag (tag-name)
  (lambda (node)
    (member tag-name (org-roam-node-tags node))))

(defun my/org-roam-list-notes-by-tag (tag-name)
  (mapcar #'org-roam-node-file
          (seq-filter
           (my/org-roam-filter-by-tag tag-name)
           (org-roam-node-list))))

; (defun my/org-roam-refresh-agenda-list ()
;   (interactive)
;   (setq org-agenda-files (my/org-roam-list-notes-by-tag "Project")))
;
; ;; Build the agenda list the first time for the session
; (my/org-roam-refresh-agenda-list)
;
; (defun my/org-roam-project-finalize-hook ()
;   "Adds the captured project file to `org-agenda-files' if the
; capture was not aborted."
;   ;; Remove the hook since it was added temporarily
;   (remove-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)
;
;   ;; Add project file to the agenda list if the capture was confirmed
;   (unless org-note-abort
;     (with-current-buffer (org-capture-get :buffer)
;       (add-to-list 'org-agenda-files (buffer-file-name)))))

(defun my/org-roam-find-project ()
  (interactive)
  ;; Add the project file to the agenda after capture is finished
  (add-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)

  ;; Select a project file to open, creating it if necessary
  (org-roam-node-find
   nil
   nil
   (my/org-roam-filter-by-tag "Project")
   :templates
   '(("p" "project" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+category: ${title}\n#+filetags: Project")
      :unnarrowed t))))

(defun my/org-roam-capture-inbox ()
  (interactive)
  (org-roam-capture- :node (org-roam-node-create)
                     :templates '(("i" "inbox" plain "* %?"
                                  :if-new (file+head "Inbox.org" "#+title: Inbox\n")))))

(defun my/org-roam-capture-task ()
  (interactive)
  ;; Add the project file to the agenda after capture is finished
  (add-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)

  ;; Capture the new task, creating the project file if necessary
  (org-roam-capture- :node (org-roam-node-read
                            nil
                            (my/org-roam-filter-by-tag "Project"))
                     :templates '(("p" "project" plain "** TODO %?"
                                   :if-new (file+head+olp "%<%Y%m%d%H%M%S>-${slug}.org"
                                                          "#+title: ${title}\n#+category: ${title}\n#+filetags: Project"
                                                          ("Tasks"))))))

(defun my/org-roam-copy-todo-to-today ()
  (interactive)
  (let ((org-refile-keep t) ;; Set this to nil to delete the original!
        (org-roam-dailies-capture-templates
          '(("t" "tasks" entry "%?"
             :if-new (file+head+olp "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n" ("Tasks")))))
        (org-after-refile-insert-hook #'save-buffer)
        today-file
        pos)
    (save-window-excursion
      (org-roam-dailies--capture (current-time) t)
      (setq today-file (buffer-file-name))
      (setq pos (point)))

    ;; Only refile if the target file is different than the current file
    (unless (equal (file-truename today-file)
                   (file-truename (buffer-file-name)))
      (org-refile nil nil (list "Tasks" today-file nil pos)))))

; (add-to-list 'org-after-todo-state-change-hook
;              (lambda ()
;                (when (equal org-state "DONE")
;                  (my/org-roam-copy-todo-to-today))))

; (setq org-agenda-custom-commands
;       '(("c" "⚡ Clarity View"
;          ((agenda ""
;                   ((org-agenda-span 1)
;                    (org-super-agenda-groups
;                     '((:name "📅 Today"
;                              :time-grid t
;                              :scheduled today
;                              :deadline past
;                              :deadline today))))
;           (alltodo ""
;                    ((org-agenda-overriding-header "")
;                     (org-super-agenda-groups
;                      '((:name "🥅 Weekly Goals"
;                               :todo "WEEKLY")
;                        (:name "🔜 Upcoming (next 7 days)"
;                               :scheduled future
;                               :scheduled (before "+7d")))))))))

; (setq org-agenda-skip-deadline-if-done t
;       org-agenda-include-deadlines t
;       org-agenda-block-separator nil
;       org-agenda-compact-blocks t
;       org-agenda-start-day nil ;; i.e. today
;       org-agenda-span 1
;       org-agenda-start-on-weekday nil
;       org-super-agenda-groups
;       '(;; Each group has an implicit boolean OR operator between its selectors.
;         (:name "Weekly"  ; Optionally specify section name
;          :todo "WEEKLY")
;
;         (:name "Errands"
;          :todo "TODAY"
;          :tag "errand")
;
;         (:name "Media"
;          :todo ("TO-READ" "TO-WATCH" "WATCHING"))
;         (:name "Other"
;          :priority<= "B")))
;
(org-super-agenda-mode)

(setq org-todo-keywords
      '((sequence "TODO(t)" "DELEGATED(D)" "WEEKLY(w)" "|" "DONE(d)" "CANCELED(c@)" )))
