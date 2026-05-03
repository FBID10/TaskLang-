# TaskLang++ — Domain-Specific Language for Task Scheduling and Workflow Automation

## 1. Domain & DSL Design

### Domain: Task Scheduling and Workflow Automation

**TaskLang++** is a domain-specific language designed to simplify the orchestration of system-level scripts and processes. It bridges the gap between simple cron jobs and complex enterprise schedulers, providing an intuitive, declarative syntax for defining automated workflows.

### Scope

TaskLang++ allows users to:

- **Task Definition:** Define named units of work (Tasks) that encapsulate executable scripts.
- **Execution Control:** Execute external scripts via string literals with clear semantic meaning.
- **Temporal Scheduling:** Support both daily and weekly schedules with precise time-of-day execution (24-hour format).
- **Dependency Management:** Enable task chaining and sequential processing by defining relationships (BEFORE/AFTER/DEPENDS_ON) between different tasks.
- **Conditional Logic:** Allow execution branches based on the success or failure of previous tasks, enabling robust error handling and recovery workflows.

### Why a Custom DSL?

While shell scripts and system cron can handle basic scheduling, TaskLang++ provides:
1. **Readability:** Declarative syntax is more human-readable than nested bash conditionals.
2. **Safety:** A formal grammar prevents ambiguous or malformed task definitions before execution.
3. **Expressiveness:** Dependencies and conditions are first-class constructs, not afterthoughts.
4. **Maintainability:** Non-technical users can understand and modify task workflows without shell scripting expertise.

---

## 2. Final Grammar (EBNF + BNF)

### Terminals (Lexical Tokens)

The **terminals** are the atomic symbols produced by the lexer:

| Token | Type | Description |
|-------|------|-------------|
| `TASK` | Keyword | Marks the start of a task definition |
| `RUN` | Keyword | Indicates the executable script to run |
| `EVERY` | Keyword | Indicates recurring schedule |
| `DAY`, `WEEK` | Keyword | Schedule frequency |
| `ON` | Keyword | Day specifier (for weekly schedules) |
| `AT` | Keyword | Time specifier |
| `AFTER`, `BEFORE` | Keyword | Dependency relationships |
| `DEPENDS_ON` | Keyword | Explicit dependency declaration |
| `IF` | Keyword | Conditional execution |
| `SUCCESS`, `FAIL` | Keyword | Success/failure conditions |
| `IDENTIFIER` | Pattern | `[a-zA-Z][a-zA-Z0-9_]*` |
| `STRING_LITERAL` | Pattern | `"[^"]*"` |
| `TIME_LITERAL` | Pattern | `[0-2][0-9]:[0-5][0-9]` (HH:MM 24-hour format) |
| `{`, `}` | Delimiter | Task block boundaries |
| `,` | Delimiter | List separator |

### Non-Terminals (Grammar Rules)

| Non-Terminal | Description |
|--------------|-------------|
| `<program>` | Root production; a collection of task definitions |
| `<task_list>` | One or more task definitions |
| `<task_def>` | A single task block with name, run, and metadata |
| `<run_stmt>` | The executable script for the task |
| `<schedule_stmt>` | When the task runs (optional, can be empty) |
| `<dep_stmt>` | Dependency/relationship declarations (optional) |
| `<cond_stmt>` | Conditional execution rules (optional) |
| `<id_list>` | Comma-separated list of task identifiers |

### Grammar Specification (EBNF)

```ebnf
program         ::= task_list

task_list       ::= task_def
                  | task_list task_def

task_def        ::= TASK IDENTIFIER "{" run_stmt schedule_stmt dep_stmt cond_stmt "}"

run_stmt        ::= RUN STRING_LITERAL

schedule_stmt   ::= ( EVERY DAY AT TIME_LITERAL )
                  | ( EVERY WEEK ON IDENTIFIER AT TIME_LITERAL )
                  | ( AT TIME_LITERAL )
                  | ε   /* empty */

dep_stmt        ::= ( AFTER identifier_list )
                  | ( BEFORE identifier_list )
                  | ( DEPENDS_ON identifier_list )
                  | ε   /* empty */

cond_stmt       ::= ( IF SUCCESS )
                  | ( IF FAIL )
                  | ε   /* empty */

identifier_list ::= IDENTIFIER
                  | identifier_list "," IDENTIFIER
```

### Key Technical Features

1. **Flexibility via Empty Productions:** Optional clauses (schedule, dependency, condition) are marked with `ε`, allowing users to write minimal task definitions or rich ones as needed.
2. **Left Recursion for Lists:** Both `task_list` and `identifier_list` use left-recursive rules (BNF standard), which Bison efficiently handles with its LR parser.
3. **Type Safety:** The identifier list ensures only valid task names are referenced, preventing typos and undefined task errors.
4. **Deterministic Parsing:** No ambiguities; each rule produces exactly one parse tree for valid input.

---

## 3. Sample Programs

### Example 1: Simple Task

```tasklang
TASK simpleTask { RUN "simple.sh" }
```

**Output:**
```
Executing Task: simpleTask
    Script: "simple.sh"
```

---

### Example 2: Task with Daily Schedule

```tasklang
TASK dailyReport { RUN "report.py" EVERY DAY AT 06:00 }
```

**Output:**
```
Executing Task: dailyReport
    Script: "report.py"
    Schedule: EVERY DAY AT 06:00
```

---

### Example 3: Multi-Task Workflow with Dependencies

```tasklang
TASK backupDB {
   RUN "backup.sh"
   EVERY DAY AT 02:00
}

TASK sendReport {
   RUN "report.py"
   AFTER backupDB
   IF success
}

TASK cleanup {
   RUN "cleanup.sh"
   EVERY WEEK ON SUNDAY AT 03:00
}
```

**Output:**
```
Executing Task: backupDB
    Script: "backup.sh"
    Schedule: EVERY DAY AT 02:00

Executing Task: sendReport
    Script: "report.py"
    Depends on: backupDB
    Condition: success

Executing Task: cleanup
    Script: "cleanup.sh"
    Schedule: EVERY WEEK ON SUNDAY AT 03:00
```

---

### Example 4: Complex Workflow with Multiple Dependencies

```tasklang
TASK preprocessing { RUN "preprocess.sh" EVERY DAY AT 01:00 }

TASK mainProcess { RUN "process.sh" AFTER preprocessing IF success }

TASK postProcess { RUN "postprocess.sh" AFTER mainProcess IF success }

TASK notify { RUN "notify.sh" AFTER preprocessing, mainProcess, postProcess IF success }
```

This demonstrates a complex workflow where `notify` depends on multiple prior tasks.

**Output:**
```
Executing Task: preprocessing
   Script: "preprocess.sh"
   Schedule: EVERY DAY AT 01:00

Executing Task: mainProcess
   Script: "process.sh"
   Depends on: preprocessing
   Condition: success

Executing Task: postProcess
   Script: "postprocess.sh"
   Depends on: mainProcess
   Condition: success

Executing Task: notify
   Script: "notify.sh"
   Depends on: preprocessing, mainProcess, postProcess
   Condition: success
```

---

## 4. Reflection: Design Trade-Offs and Challenges

### Design Trade-Offs

1. **Simplicity vs. Expressiveness**
   - **Trade-off:** We chose a simpler, more readable syntax at the cost of some expressiveness.
   - **Rationale:** Users prefer clarity over Turing-completeness for task scheduling. Complex logic should live in the scripts themselves, not the scheduler.

2. **Fixed Time Format (HH:MM)**
   - **Trade-off:** We restrict times to 24-hour format (HH:MM) instead of supporting cron-style expressions or epoch timestamps.
   - **Rationale:** HH:MM is human-readable and sufficient for most scheduling needs. Full cron expressions would complicate the lexer and parser.

3. **Static Scheduling Only**
   - **Trade-off:** No dynamic scheduling (e.g., "run every N minutes" or "run when disk usage > 80%").
   - **Rationale:** For dynamic triggers, users can wrap the script in their own monitoring logic. This keeps TaskLang++ focused on time-based schedules.

4. **Run-Time Simulation, Not Execution**
   - **Trade-off:** The current interpreter prints what *would* execute but doesn't actually run scripts.
   - **Rationale:** This is a parser/simulator assignment. A production system would fork processes and track state; that's beyond scope here.

### Key Challenges

1. **Handling Optional Clauses**
   - **Challenge:** Tasks can omit schedule, dependency, and condition clauses, leading to many grammar rules with empty productions.
   - **Solution:** We used EBNF's `ε` (empty) productions and made them explicit in the grammar. Bison handles empty productions cleanly with LR parsing.

2. **Dependency Resolution & Circular References**
   - **Challenge:** Users could define circular dependencies (Task A depends on B, B depends on A).
   - **Current Approach:** We parse and accept them; the runtime/executor would detect and report these errors. Full semantic analysis of the DAG (directed acyclic graph) is left for the execution phase.

3. **Lexer Ambiguity with Keywords**
   - **Challenge:** Distinguishing between reserved keywords like `EVERY` and user-defined identifiers.
   - **Solution:** We define keywords in the lexer with exact string matches (`"EVERY"`, `"DAY"`, etc.) before the generic `IDENTIFIER` rule, ensuring keywords take precedence.

4. **Time Format Validation**
   - **Challenge:** Enforcing HH:MM format where 00-23 for hours and 00-59 for minutes.
   - **Solution:** We use a regex pattern `[0-2][0-9]:[0-5][0-9]` in the lexer, which is close but not perfect (e.g., `29:45` is lexed as `TIME_LITERAL` but is invalid). A full semantic check could be added in the parser actions.

### Improvements for Future Work

1. **Semantic Analysis Pass**
   - Add a post-parse phase to validate:
     - All referenced tasks in dependencies exist.
     - No circular dependencies.
     - Time values are valid (00:00 – 23:59).

2. **Extended Schedule Expressions**
   - Support more flexible scheduling: `EVERY 2 DAYS`, `EVERY 30 MINUTES`, `ON SPECIFIC DATES`.

3. **Condition Operators**
   - Expand conditions beyond `IF SUCCESS` / `IF FAIL` to support `IF TIMEOUT`, `IF RETRIES_EXCEEDED`, etc.

4. **Actual Execution Engine**
   - Implement a runtime that:
     - Forks processes to run scripts.
     - Tracks execution history and logs.
     - Manages state across multiple runs.

5. **Error Recovery**
   - Implement better error recovery in the parser to report multiple errors in one pass (not just the first).

### Lessons Learned

- **Left-Recursion is Powerful:** Using left-recursion in Bison is much more efficient than right-recursion for parsing lists.
- **Line-Number Tracking is Essential:** Adding `%option yylineno` to the lexer and exposing `yylineno` in error messages dramatically improves debugging.
- **Test Automation Catches Issues Early:** Our test suite (with both valid and error cases) caught edge cases and ensured robustness before final submission.

---

## Building and Running

### Build
```bash
make
```

### Run
```bash
# Parse a file
./TaskLang task_file.txt

# Interactive mode (submit empty line to finish)
./TaskLang
```

### Test
```bash
make test
```

This runs the automated test suite covering valid tasks, dependencies, schedules, and error conditions.

---

## Files Included

- `TaskLang.l` — Lexer (Flex)
- `TaskLang.y` — Parser (Bison)
- `Makefile` — Build configuration and test target
- `test.sh` — Automated test suite
- `tests/` — Test cases (valid and error scenarios)
- `README.md` — This documentation

---

## Conclusion

TaskLang++ successfully implements a clean, expressive domain-specific language for task scheduling. The combination of Flex (lexer) and Bison (parser) provides a robust foundation for parsing and simulating complex workflows. The design prioritizes readability and maintainability over raw expressiveness, making it suitable for users who need reliable task orchestration without the complexity of shell scripting or enterprise schedulers.
