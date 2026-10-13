const std = @import("std");

pub fn main(init: std.process.Init) !void{
    //iniciamos o arena allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    
    //iniciamos o Io
    const io = init.io;
    defer arena.deinit();

    const allocator = arena.allocator();

    //alocamos memoria
    const memoria = try allocator.create([512]u8);
    defer allocator.destroy(memoria);

    //pegamos o diretorio local
    const diretorio = std.Io.Dir.cwd();
    
    //abrimos o arquivo
    const file = try diretorio.openFile(io, "binario.bin",.{});
    defer file.close(io);

    const buffer_file = try diretorio.readFileAlloc(io, "binario.bin", allocator, .limited(10 * 1024 * 1024));

    defer allocator.free(buffer_file);        

    const teste = verificar_mbr(buffer_file);

    std.debug.print("{s}\n", .{teste});


}

pub fn verificar_mbr(mbr: []u8) []const u8{
    if (mbr.len < 512){
        return "Arquivo não é mbr";
    }
    if (mbr[510] == 0x55 and mbr[511] == 0xAA){
        return "Little-Endian";
    }

    if (mbr[510] == 0xAA and mbr[511] == 0x55){
        return "Big-Endian";
    }
    else{
        return "Arquivo não é mbr";   
    }
}
