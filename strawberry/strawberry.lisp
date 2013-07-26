;;
;; Harold Lee
;; harold@hotelling.net
;;
;; Please see the attached README.md file for more details.
;;
;; To run this program, load this package and then run
;;
;; (strawberry:runall)
;;

(defpackage :strawberry
  (:nicknames :sb)
  (:use :common-lisp)
  (:export "RUNALL" "*FILE-NAME*"
           "B" "BB" "RUN-TRIV" "RUNME" "EST-SPACE"))

(in-package :strawberry)

(defconstant +maximum-side-length+ 50
  "The maximum width or height of a field of strawberries.")

(defvar *file-name* "rectangles.txt"
  "The file to work with")

(defstruct board 
  "Describes a problem read in from the file: a field of strawberries to cover with greenhouses."
  max-houses field-map 
  (width 0) (height 0) 
  layout)

(defstruct house 
  "Describes a greenhouse with upper-left corner (x1,y1) and lower-right corner (x2,y2)."
  x1 y1 x2 y2)





;;; Some straight-forward utility functions for houses

(defun house-area (h)
  "How many squares does a greenhouse cover?"
  (* (- (1+ (house-x2 h)) (house-x1 h))
     (- (1+ (house-y2 h)) (house-y1 h))))

(defun house-cost (h)
  "Find out how much a given greenhouse would cost"
  (+ 10 (house-area h)))

(defun merge-houses (&rest houses)
  "Find the bounding rectangle of two or more greenhouses"
  (loop for h in houses
     minimize (house-x1 h) into x1
     maximize (house-x2 h) into x2
     minimize (house-y1 h) into y1
     maximize (house-y2 h) into y2
     finally (return (make-house :x1 x1 :x2 x2 :y1 y1 :y2 y2))))

(defun intersect-houses (&rest houses)
  "Find the intersection, if any, between space covered by the houses."
  (loop for h in houses
     maximize (house-x1 h) into x1 of-type (unsigned-byte 8)
     minimize (house-x2 h) into x2 of-type (unsigned-byte 8)
     maximize (house-y1 h) into y1 of-type (unsigned-byte 8)
     minimize (house-y2 h) into y2 of-type (unsigned-byte 8)
     finally (return (when (and (>= x2 x1) (>= y2 y1))
                       (make-house :x1 x1 :x2 x2 :y1 y1 :y2 y2)))))

(defun merge-waste (&rest houses)
  "How many non-strawberry squares will be wasted if these houses are merged"
  (- (house-area (apply #'merge-houses houses))
     (apply #'+ (mapcar #'house-area houses))))

(defun house-contains-p (h1 h2)
  "Does h1 contain h2?"
  (and (>= (house-x1 h2) (house-x1 h1))
       (<= (house-x2 h2) (house-x2 h1))
       (>= (house-y1 h2) (house-y1 h1))
       (<= (house-y2 h2) (house-y2 h1))))

(defun sort-layout (houses)
  "Sort the houses so that the same houses will end up in the same order"
  (sort houses #'< :key (lambda (h) 
                          (+ (* +maximum-side-length+ (house-x1 h)) 
                             (house-y1 h)))))






;;; Functions to read in and parse the boards

(defun read-boards ()
  "Read in the list of strawberry fields to cover"
  (let (boards)
    (with-open-file(f *file-name*)
      (loop for max-houses = (read f nil)
            for field-map = (loop for line = (read-line f nil)
                                  while (and line (string/= line ""))
                                  collect line)
            while (and max-houses field-map)
            do (push (make-board :max-houses max-houses
                                 :field-map field-map)
                     boards)))
    (nreverse boards)))

(defun parse-board (b)
  "Initialize the layout with one greenhouse per strawberry - pretty wasteful!"
  (let ((fm (board-field-map b))
        (houses nil)
        (i 0)
        (j 0)
        (max-j 0))
    (loop for row in fm
          do (progn (setq j 0)
                    (loop for c across row
                          do (progn (when (char= c #\@)
                                      (push (make-house :x1 i :x2 i :y1 j :y2 j)
                                            houses))
                                    (incf j)))
                    (when (> j max-j)
                      (setq max-j j))
                    (incf i)))
    (setf (board-height b) i)
    (setf (board-width  b) j)
    (when (or (> (board-width  b) +maximum-side-length+)
              (> (board-height b) +maximum-side-length+))
      (error "The board is too big!"))
    (nreverse houses)))






;;; Functions to merge adjacent houses when there is no waste introduced

(defun merges-containing (h merges)
  (remove-if-not (lambda (m)
                   (member h m :test 'equalp))
                 merges))

(defun contested-house-p (h merges houses)
  (let ((other-houses (remove-duplicates (apply #'append
                                                (merges-containing h merges))
                                         :test 'equalp)))
    (when other-houses
      (let* ((merger   (apply #'merge-houses other-houses))
             (subsumed (remove-if-not (lambda (h)
                                        (house-contains-p merger h)) 
                                      houses)))
        (< 0 (apply #'merge-waste subsumed))))))

(defun pairs (some-list)
  (apply #'append
         (maplist (lambda (hs)
                    (loop with item = (car hs)
                          for partner in (cdr hs)
                          when (and item partner)
                          collect (list item partner)))
                  some-list)))

(defun perform-merge (merge layout)
  "Perform the merge, adding the new (merged) house and removing the old houses that were merged."
  (let ((new-house (apply #'merge-houses merge)))
    (cons new-house
          (remove-if (lambda (h) (house-contains-p new-house h))
                     layout))))

(defun layout-cost (layout)
  "Find the total cost of a greenhouse layout plan."
  (loop for house in layout
        sum (house-cost house)))

(defun free-merge-p (h1 h2 lookup)
  (let ((h (merge-houses h1 h2)))
    (loop for i from (house-x1 h) to (house-x2 h)
          do (loop for j from (house-y1 h) to (house-y2 h)
                   do (when (not (gethash (cons i j) lookup))
                        (return-from free-merge-p nil)))))
  t)

(defun expand-house (h lookup)
  (let ((x1 (house-x1 h)) (x2 (house-x2 h))
        (y1 (house-y1 h)) (y2 (house-y2 h))
        new-x1 new-x2 new-y1 new-y2)
    ;; check above to see how far up we can go
    (setq new-x1
          (loop for i downfrom (1- x1) to -1
                when (member nil (loop for j from y1 to y2 
                                       collect (gethash (cons i j) lookup)))
                return (1+ i)))
    ;; check to the left to see how far over we can go
    (setq new-y1
          (loop for j downfrom (1- y1) to -1
                when (member nil (loop for i from x1 to x2 
                                       collect (gethash (cons i j) lookup)))
                return (1+ j)))
    ;; check below to see how far down we can go
    (setq new-x2
          (loop for i from (1+ x2) to +maximum-side-length+
                when (member nil (loop for j from y1 to y2 
                                       collect (gethash (cons i j) lookup)))
                return (1- i)))
    ;; check to the right to see how far over we can go
    (setq new-y2
          (loop for j from (1+ y2) to +maximum-side-length+
                when (member nil (loop for i from x1 to x2 
                                       collect (gethash (cons i j) lookup)))
                return (1- j)))
    (make-house :x1 new-x1 :x2 new-x2 :y1 new-y1 :y2 new-y2)))

(defun trivial-merges (houses)
  (let ((lookup (make-layout-lookup houses))
        (partitioning (make-hash-table :test 'equalp))
        (results nil))
    (loop for h in houses 
          do (push h (gethash (expand-house h lookup) 
                              partitioning)))
    (maphash (lambda (k v) 
               (declare (ignore k))
               ;;(format t "~&Processing partition ~D~%" v)
               (loop while v
                     do (let ((a (car v))
                              (as (cdr v)))
                          (let ((new-merge (cons a (remove-if-not (lambda (h)
                                                                    (free-merge-p a h (make-layout-lookup v)))
                                                                  as))))
                            ;;(format t "~&Adding merge ~D~%" new-merge)
                            (setq v (set-difference v new-merge :test 'equalp))
                            (push (apply #'merge-houses new-merge) results))))
               nil)
             partitioning)
    ;;(format t "~&Done merging, the result is: ~D~%" results)
    results))






;;; Functions for searching for the best layout

(defun safe-merges (merges layout)
  "Remove any merges from consideration if the merged house would intersect a third house."
  (remove-if (lambda (m)
               (let ((new-house (apply #'merge-houses m))
                     (other-houses (set-difference layout m :test 'equalp)))
                 (some #'house-p (mapcar (lambda (h)
                                           (intersect-houses new-house h))
                                         other-houses))))
             merges))

(defun least-waste-merges (merges)
  (let (least-waste kept-merges)
    (loop for merge in merges
          do (let ((waste (apply #'merge-waste merge)))
               (cond ((not least-waste)     (progn (setq least-waste waste)
                                                   (push merge kept-merges)))
                     ((< waste least-waste) (progn (setq least-waste waste)
                                                   (setq kept-merges (list merge))))
                     ((= waste least-waste) (push merge kept-merges)))))
    kept-merges))

(defun reductions (layout)
  (mapcar (lambda (m) 
            (trivial-merges (perform-merge m layout)))
          (least-waste-merges (safe-merges (pairs layout) layout))))

(defun depth-first-search (b)
  "Search for the best layout for this board by trying different combinations of 
merges that produce waste."
  (let ((q (list (trivial-merges (parse-board b))))
        (best nil)
        (best-cost nil)
        (visited-layouts  (make-hash-table :test 'equalp))
        (num-considered 0))
    (setf (gethash (car q) visited-layouts) t)
    (loop while q
          do (let ((n (car q)))
               (setq q (cdr q))
               (incf num-considered)
               ;; if this layout is cheaper, update the best
               (when (and (or (not best)
                              (< (layout-cost n) best-cost))
                          (<= (length n) (board-max-houses b)))
                 ;;(format t "~&New best: ~D ~D beats ~D ~D~%" n (layout-cost n) best best-cost)
                 (setq best n)
                 (setq best-cost (layout-cost n)))
               ;; add each reduction of this layout to the queue
               (let ((next-steps (remove-if (lambda (new-layout)
                                              (gethash new-layout visited-layouts))
                                            (reductions n))))
                 ;;(when (not next-steps) (format t "~&Hit bottom with ~D layouts checked.~%" num-considered))
                 ;;(mapcar #'sort-layout next-steps)
                 (dolist (step next-steps)
                   (setf (gethash step visited-layouts) t))
                 (setq q (append next-steps q)))))
    (values best num-considered)))







;;; Functions for printing out a solution to a board

(let ((house-names (concatenate 'string
                                  "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                  (make-string (* +maximum-side-length+ 
                                                  +maximum-side-length+)
                                               :initial-element #\_))))
  (defun make-layout-lookup (layout)
    (let ((lookup (make-hash-table :test 'equalp)))
      (loop for h in layout
            for c across house-names
            do (loop for i from (house-x1 h) to (house-x2 h)
                     do (loop for j from (house-y1 h) to (house-y2 h)
                              do (setf (gethash (cons i j) lookup) c))))
      lookup)))

(defun print-layout (board)
  "Print to the screen a visual layout of the greenhouses."
  (let ((layout (board-layout board))
        (max-x  (1- (board-height board)))
        (max-y  (1- (board-width  board))))
    (format t "~D~%" (layout-cost layout))
    (let ((lookup (make-layout-lookup layout)))
      (loop for i from 0 to max-x
            do (progn (loop for j from 0 to max-y
                            do (let ((name (gethash (cons i j) lookup)))
                                 (if name (princ name)
                                     (princ #\.))))
                      (terpri)))))
  (terpri))






;; Funtions to run the program

(defvar b nil  "For debugging, the last board processed.")
(defvar bb nil "For debugging, the last board's layout.")

(defun run-triv (n)
  "Run the trivial merge algorithm for the nth board and print the result."
  (setq b (nth n (read-boards)))
  (setf (board-layout b) (trivial-merges (parse-board b)))
  (setq bb (board-layout b))
  (print-layout b))

(defun runme (n)
  "Run the program for only the nth board."
  (setq b (nth n (read-boards)))
  (setf (board-layout b) (trivial-merges (parse-board b)))
  (multiple-value-bind (new-layout num-considered)
      (depth-first-search b)
    (setf (board-layout b) new-layout)
    (format t "~&Checked ~D layouts.~%" num-considered))
  (setq bb (board-layout b))
  (print-layout b))

(defun est-space (n)
  "Estimate the search space for the nth board in the file by doing a 
left-deep walk, multiplying the number of reductions possible at each 
node on the path but always just taking the first one."
  (run-triv n)
  (let* ((result 1)
         (x bb)
         (r (reductions x)))
    (loop (when (or (not x) (<= (length r) 1))
            (return))
          (setq result (* result (max 1 (length r))))
          (setq x (car r))
          (setq r (reductions x)))
    (format t "~&Estimated size of the search space is ~D~%" result)))
;; 4: (* 153 91 55 36 21 6 3 1)

(defun runall ()
  "This is the main routine for the program.
Run this to get answers for everything."
  (dolist (b (read-boards))
    (setf (board-layout b) (trivial-merges (parse-board b)))
    (setf (board-layout b) (depth-first-search b))
    (print-layout b)))
