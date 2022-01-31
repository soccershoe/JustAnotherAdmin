---
layout: post
title: "AD Object Exceeded Size"
date: 2019-02-14
---

Future Post

{{ more }}

I had several AD objects where the 'memberUid' attribute wasn't able to be updated.  The objects were also not able to be deleted.  That's strange.  Why wouldn't I be able to delete an object in AD?  

Worked with Microsoft.  Did some ldifde things.  And figured it out.  

The 'memberUid' field is calculated field and can not exceed a certain size.  We exceeded that size.  

I'll fill in the details latersss.