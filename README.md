**Work in progress!** Based on the plugin by Mr F, but almost everything has been rewritten.

3ds Max 2009 or newer required.

<img width="600" height="360" src="https://i.postimg.cc/HxvRb652/hotrodp200.png">

**What is supported:**
- Sectors
- Portals
- Meshes
- LODs
- Dummies
- [Material flags](https://user-images.githubusercontent.com/39903631/84805351-67706b80-b004-11ea-846a-2d633223620a.png)
- Culling and rendering flags
- Vertex normals (smoothing groups, or explicit normals)

**What is not supported (yet?):**
- Skinned meshes, morphs, bones, billboards, mirrors, targets, glows, instanced geometry. Files containing these types can be opened, but they will be imported only partially.  

See [**roadmap**](ROADMAP.md)


Sectors have to be prefixed with "sector" (no dollar sign)  
Portals have to be prefixed with "$portal" and have a sector parent  
Lods have to be prefixed with "$lod" and have a mesh parent

You can apply optional modifiers to control culling flags, lod fade distance, portal range...

scene.4ds files can be imported & exported without losing lighting or collisions (depends on how much you edit)

~~Current limitations: Materials have to be under single Multimaterial with a name "$MAFIA_MATERIALS"~~

If you move pivot for an object, you have to reset it before exporting.

**How to install:**  
[Download here](https://github.com/pudingus/mafia-4ds-import-export/releases)  
Extract the files in "C:\Program Files\Autodesk\3ds Max 2020\scripts" and restart 3ds Max.

**How to use:**  
Open command panel and the utility panel, there you should see a "Mafia 4ds Tools" rollout.  
To see textures, hit Customize in the top menu > Configure Project Paths > External files. And there add your Mafia "maps" folder.
