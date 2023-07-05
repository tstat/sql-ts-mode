;;; sql-ts-mode.el --- tree-sitter support for SQL  -*- lexical-binding: t; -*-

;; Author: Travis Staton
;; Version: 0.1.0
;; Keywords: sql languages tree-sitter
;; URL: https://github.com/tstat/sql-ts-mode
;; Package-Requires: ((emacs "29"))

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

;;; Code:

(require 'treesit)

(declare-function treesit-parser-create "treesit.c")

(defvar sql-ts-mode--treesit-font-lock-settings
  (treesit-font-lock-rules

   :language 'sql
   :feature 'function
   '((invocation name: (identifier) @font-lock-function-use-face)
     )

   :language 'sql
   :feature 'keyword
   '([(keyword_asc)
      (keyword_desc)
      (keyword_null)
      (keyword_terminated)
      (keyword_escaped)
      (keyword_unsigned)
      (keyword_nulls)
      (keyword_last)
      (keyword_delimited)
      (keyword_replication)
      (keyword_auto_increment)
      (keyword_default)
      (keyword_collate)
      (keyword_concurrently)
      (keyword_engine)
      (keyword_preceding)
      (keyword_following)
      (keyword_first)
      (keyword_materialized)
      (keyword_temp)
      (keyword_temporary)
      (keyword_unlogged)
      (keyword_external)
      (keyword_parquet)
      (keyword_csv)
      (keyword_rcfile)
      (keyword_textfile)
      (keyword_orc)
      (keyword_avro)
      (keyword_jsonfile)
      (keyword_sequencefile)
      (keyword_case)
      (keyword_when)
      (keyword_then)
      (keyword_else)
      (keyword_select)
      (keyword_from)
      (keyword_where)
      (keyword_index)
      (keyword_join)
      (keyword_primary)
      (keyword_delete)
      (keyword_create)
      (keyword_insert)
      (keyword_distinct)
      (keyword_replace)
      (keyword_update)
      (keyword_into)
      (keyword_values)
      (keyword_set)
      (keyword_left)
      (keyword_right)
      (keyword_outer)
      (keyword_inner)
      (keyword_order)
      (keyword_partition)
      (keyword_group)
      (keyword_with)
      (keyword_as)
      (keyword_having)
      (keyword_limit)
      (keyword_offset)
      (keyword_table)
      (keyword_key)
      (keyword_constraint)
      (keyword_force)
      (keyword_use)
      (keyword_for)
      (keyword_if)
      (keyword_exists)
      (keyword_max)
      (keyword_min)
      (keyword_avg)
      (keyword_column)
      (keyword_cross)
      (keyword_lateral)
      (keyword_alter)
      (keyword_drop)
      (keyword_add)
      (keyword_view)
      (keyword_end)
      (keyword_is)
      (keyword_using)
      (keyword_between)
      (keyword_window)
      (keyword_no)
      (keyword_data)
      (keyword_type)
      (keyword_rename)
      (keyword_to)
      (keyword_schema)
      (keyword_owner)
      (keyword_union)
      (keyword_all)
      (keyword_except)
      (keyword_intersect)
      (keyword_returning)
      (keyword_begin)
      (keyword_commit)
      (keyword_rollback)
      (keyword_transaction)
      (keyword_only)
      (keyword_like)
      (keyword_similar)
      (keyword_over)
      (keyword_change)
      (keyword_modify)
      (keyword_after)
      (keyword_range)
      (keyword_rows)
      (keyword_groups)
      (keyword_exclude)
      (keyword_current)
      (keyword_ties)
      (keyword_others)
      (keyword_preserve)
      (keyword_zerofill)
      (keyword_format)
      (keyword_fields)
      (keyword_row)
      (keyword_sort)
      (keyword_compute)
      (keyword_comment)
      (keyword_partitioned)
      (keyword_location)
      (keyword_cached)
      (keyword_uncached)
      (keyword_lines)
      (keyword_stored)
      (keyword_location)
      (keyword_partitioned)
      (keyword_cached)
      (keyword_restrict)
      (keyword_unbounded)
      (keyword_unique)
      (keyword_cascade)
      (keyword_ignore)
      (keyword_gist)
      (keyword_btree)
      (keyword_hash)
      (keyword_spgist)
      (keyword_gin)
      (keyword_brin)
      (keyword_array)
      ] @font-lock-keyword-face
     )

   :language 'sql
   :feature 'comment
   '((comment) @font-lock-comment-face)

   :language 'sql
   :feature 'literal
   '((literal "'") @font-lock-string-face
     (identifier) @font-lock-function-name-face
     (literal "\"") @font-lock-variable-name-face
     ((literal) @int (:match "^[[:digit:]]+$" @int)) @font-lock-number-face
     ((literal) @float (:match "^[-]?[[:digit:]]+\\.[[:digit:]]+$" @float)) @font-lock-number-face
     ;; todo: why isn't the above float rule working? It seems to match with treesit-query-string
     )

   :language 'sql
   :feature 'operator
   '(
     (keyword_in)
     (keyword_and)
     (keyword_or)
     (keyword_not)
     (keyword_by)
     (keyword_on)
     (binary_expression operator: _ @font-lock-operator-face)
     )

   :language 'sql
   :feature 'type
   '(
     [(keyword_int)
     (keyword_boolean)
     (keyword_character)
     (keyword_smallserial)
     (keyword_serial)
     (keyword_bigserial)
     (keyword_smallint)
     (keyword_bigint)
     (keyword_tinyint)
     (keyword_decimal)
     (keyword_float)
     (keyword_numeric)
     (keyword_real)
     (double)
     (keyword_money)
     (keyword_char)
     (keyword_varchar)
     (keyword_text)
     (keyword_uuid)
     (keyword_json)
     (keyword_jsonb)
     (keyword_xml)
     (keyword_bytea)
     (keyword_date)
     (keyword_datetime)
     (keyword_timestamp)
     (keyword_timestamptz)
     (keyword_geometry)
     (keyword_geography)
     (keyword_box2d)
     (keyword_box3d)
     (keyword_interval)] @font-lock-type-face
     )
   )
  "Tree-sitter font-lock settings for `sql-ts-mode'.")

(defvar sql-ts-mode--indent-level
  2
  "How many spaces to indent for `sql-ts-mode'.")

(defvar sql-ts-mode--treesit-indent-rules
  '((sql
     ((node-is "column_definition") parent-bol sql-ts-mode--indent-level)
     ((node-is "select_expression") parent-bol sql-ts-mode--indent-level)
     ((node-is "from") parent-bol 0)
     ((node-is "ERROR") parent-bol 0)
     ((node-is "where") parent-bol 0)
     ((node-is "order_by") parent-bol 0)
     ((node-is "limit") parent-bol 0)
     ((parent-is "from") parent-bol sql-ts-mode--indent-level)
     ((parent-is "join") parent-bol sql-ts-mode--indent-level)
     ((parent-is "where") parent-bol sql-ts-mode--indent-level)
     ((parent-is "order_by") parent-bol sql-ts-mode--indent-level)
     ((parent-is "limit") parent-bol sql-ts-mode--indent-level)
     ((parent-is ".*") prev-line 0)
     ))
  "Tree-sitter indentation settings for `sql-ts-mode'.")

;;;###autoload
(define-derived-mode sql-ts-mode sql-mode "SQL (TS)"
  "Major mode for SQL files using tree-sitter"
  :group 'sql

  (unless (treesit-ready-p 'sql)
    (error "Tree-sitter for SQL is not available"))

  (treesit-parser-create 'sql)

  ;; Font-lock
  (setq-local treesit-font-lock-settings sql-ts-mode--treesit-font-lock-settings)
  (setq-local treesit-font-lock-feature-list
              '(( function keyword comment literal operator type)))
  ;; Indent
  (setq-local treesit-simple-indent-rules sql-ts-mode--treesit-indent-rules)

  (treesit-major-mode-setup))

(provide 'sql-ts-mode)

;;; sql-ts-mode.el ends here
