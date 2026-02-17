# CQL Pattern Reference

Ready-to-use Confluence Query Language recipes. Use with: `confluence search "CQL"`

---

## Full-Text Search

**Body and title text match**
```
text ~ "deployment checklist"
```
```bash
confluence search "text ~ 'deployment checklist'"
```

**Text match scoped to a space**
```
text ~ "API" AND space = "DEV"
```
```bash
confluence search "text ~ 'API' AND space = 'DEV'"
```

---

## Title Search

**Exact title match**
```
title = "Architecture Overview"
```
```bash
confluence search "title = 'Architecture Overview'"
```

**Title contains a term**
```
title ~ "architecture"
```
```bash
confluence search "title ~ 'architecture'"
```

---

## Space-Scoped

**All pages in a space**
```
type = page AND space = "ENG"
```
```bash
confluence search "type = page AND space = 'ENG'"
```

**Blog posts in a space**
```
type = blogpost AND space = "TEAM"
```
```bash
confluence search "type = blogpost AND space = 'TEAM'"
```

---

## Labels

**Pages with a specific label**
```
label = "approved" AND type = page
```
```bash
confluence search "label = 'approved' AND type = page"
```

**Pages with any of several labels**
```
label IN ("approved", "reviewed")
```
```bash
confluence search "label IN ('approved', 'reviewed')"
```

---

## Date Filters

**Modified in the last 7 days**
```
lastModified > now("-7d")
```
```bash
confluence search "lastModified > now('-7d')"
```

**Recently created pages in a space**
```
created > now("-30d") AND space = "DEV"
```
```bash
confluence search "created > now('-30d') AND space = 'DEV'"
```

---

## Ancestor (Hierarchy)

**All descendants of a page**
```
ancestor = 12345678
```
```bash
confluence search "ancestor = 12345678"
```

---

## Combined

**API design pages in DEV, most recently modified first**
```
type = page AND space = "DEV" AND text ~ "API design" ORDER BY lastmodified DESC
```
```bash
confluence search "type = page AND space = 'DEV' AND text ~ 'API design' ORDER BY lastmodified DESC"
```
