# JQL Pattern Reference

Ready-to-use Jira Query Language recipes. Use with: `jira issue list -q "JQL" --plain`

---

## My Work

**My open issues**
```
assignee = currentUser() AND status != Done
```
```bash
jira issue list -q "assignee = currentUser() AND status != Done" --plain
```

**My in-progress issues**
```
assignee = currentUser() AND status = "In Progress"
```
```bash
jira issue list -q "assignee = currentUser() AND status = \"In Progress\"" --plain
```

**Assigned to me, overdue**
```
assignee = currentUser() AND duedate < now()
```
```bash
jira issue list -q "assignee = currentUser() AND duedate < now()" --plain
```

---

## Sprint

**Current sprint issues**
```
sprint in openSprints()
```
```bash
jira issue list -q "sprint in openSprints()" --plain
```

**Current sprint, not done**
```
sprint in openSprints() AND status != Done
```
```bash
jira issue list -q "sprint in openSprints() AND status != Done" --plain
```

**Next sprint**
```
sprint in futureSprints()
```
```bash
jira issue list -q "sprint in futureSprints()" --plain
```

**Backlog (no sprint assigned)**
```
sprint IS EMPTY AND status = "To Do"
```
```bash
jira issue list -q "sprint IS EMPTY AND status = \"To Do\"" --plain
```

---

## Triage

**Unassigned high-priority bugs**
```
type = Bug AND priority in (High, Highest) AND assignee IS EMPTY
```
```bash
jira issue list -q "type = Bug AND priority in (High, Highest) AND assignee IS EMPTY" --plain
```

**Recently created bugs (last 7 days)**
```
type = Bug AND created >= -7d
```
```bash
jira issue list -q "type = Bug AND created >= -7d" --plain
```

**Blocked issues**
```
status = Blocked
```
```bash
jira issue list -q "status = Blocked" --plain
```

**No epic assigned**
```
"Epic Link" IS EMPTY AND type != Epic
```
```bash
jira issue list -q "\"Epic Link\" IS EMPTY AND type != Epic" --plain
```

---

## Review

**Updated today**
```
updated >= startOfDay()
```
```bash
jira issue list -q "updated >= startOfDay()" --plain
```

**Updated this week**
```
updated >= startOfWeek()
```
```bash
jira issue list -q "updated >= startOfWeek()" --plain
```

**Resolved this sprint**
```
sprint in openSprints() AND status = Done
```
```bash
jira issue list -q "sprint in openSprints() AND status = Done" --plain
```

---

## Cross-Project

**All open issues across projects, by priority**
```
project IS NOT EMPTY AND status != Done ORDER BY priority DESC
```
```bash
jira issue list -q "project IS NOT EMPTY AND status != Done ORDER BY priority DESC" --plain
```
