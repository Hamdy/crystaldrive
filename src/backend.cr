require "crystalstore"
require "./models"

class CrystalDrive::Backend
    STORE = CrystalStore::Store.new

    private def self.is_file(path : String)
        return false
    end

    private def self.get_sorting_pref_for_user(id : String)
        return CrystalDrive::SortingPrefernces.new
    end

    private def self.get_content_type (http_content_type : String)
        if http_content_type.includes?("image")
            return "image"
        elsif http_content_type.includes?("text")
            return "text"
        elsif http_content_type.includes?("video")
            return "video"
        else
            return "blob"
        end
    end

    def self.dir_create(path : String, mode : Int16, create_parents : Bool = false)
        STORE.dir_create path: path, mode: mode, create_parents: create_parents
    end

    def self.dir_delete(path : String)
        STORE.dir_delete path: path
    end

    def self.dir_copy(src : String, dest : String)
        STORE.dir_copy src: src, dest: dest
    end

    def self.dir_move(src : String, dest : String)
        STORE.dir_move src: src, dest: dest
    end

    def self.file_create(path : String, mode : Int16, content_type : String, create_parents : Bool = false)
        STORE.file_create path: path, mode: mode, flags: 0_i16, content_type: content_type, create_parents: create_parents
    end

    def self.file_open(path : String, mode : Int16)
        STORE.file_open path: path, mode: mode, flags: 0_i16
    end

    def self.file_delete(path : String)
        STORE.file_delete path: path
    end

    def self.file_exists?(path : String)
        STORE.file_exists? path: path
    end

    def self.file_copy(src : String, dest : String)
        STORE.file_copy src: src, dest: dest
    end

    def self.file_move(src : String, dest : String)
        STORE.file_move src: src, dest: dest
    end

    def self.file_stats(path : String)
        file_meta = STORE.file_stats path: path
        file_meta = file_meta.not_nil!

        basename = Path.new("/", path).basename
        item = CrystalDrive::Item.new
        item.name = file_meta.not_nil!.name.not_nil!
        item.size = file_meta.not_nil!.size
        item.path = path
        item.extension = File.extname(item.name)
        item.modified = Time.unix(file_meta.not_nil!.last_modified).to_s("%Y-%m-%dT%H:%M:%S")
        item.mode = 493 #file_meta.not_nil!.mode.to_u16
        item.is_dir = false
        item.itemType = self.get_content_type file_meta.not_nil!.content_type
        return item
    end 

    def self.list(path : String = "/")
        basename = Path.new("/", path).basename
        list  = STORE.dir_list(path)
        files = list.files
        dirs = list.dirs

        result = CrystalDrive::DirList.new
        result.size = list.size
        result.modified = Time.unix(list.last_modified).to_s("%Y-%m-%dT%H:%M:%S")
        result.mode = list.mode.to_i64
        result.path = path
        result.name = basename
        result.num_dirs = list.dirs.size.to_u64
        result.num_files = list.files.size.to_u64
        result.sorting = get_sorting_pref_for_user ""

        files.each do |file|
            item = CrystalDrive::Item.new
            item.name = file.meta.not_nil!.name.not_nil!
            item.size = file.meta.not_nil!.size
            item.path = Path.new("/", item.name).to_s
            item.extension = File.extname(file.name)
            item.modified = Time.unix(file.meta.not_nil!.last_modified).to_s("%Y-%m-%dT%H:%M:%S")
            item.mode = file.meta.not_nil!.mode.to_u16
            item.is_dir = false
            item.itemType = self.get_content_type file.meta.not_nil!.content_type
            result.items << item
        end

        dirs.each do |dir|
            item = CrystalDrive::Item.new
            item.name = dir.meta.not_nil!.name.not_nil!
            item.size = dir.meta.not_nil!.size
            item.path = Path.new("/", item.name).to_s
            item.extension = ""
            item.modified = Time.unix(dir.meta.not_nil!.last_modified).to_s("%Y-%m-%dT%H:%M:%S")
            item.mode = dir.meta.not_nil!.mode.to_u16
            item.is_dir = true
            item.itemType = ""
            result.items << item
        end
        result

    end

    def self.stats(path : String)
        self.is_file(path) ? STORE.file_stats(path) : STORE.dir_stats(path)
    end
end