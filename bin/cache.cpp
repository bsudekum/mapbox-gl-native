#include <mbgl/storage/default_file_source.hpp>
#include <mbgl/storage/resource.hpp>
#include <mbgl/util/chrono.hpp>
#include <mbgl/util/run_loop.hpp>

#include <args.hxx>

#include <fstream>
#include <iostream>
#include <memory>
#include <string>
#include <unordered_map>

std::shared_ptr<std::string> readFile(const std::string& fileName) {
    std::ifstream stream(fileName);

    if (!stream.good()) {
        std::cerr << "Error: cannot read file " << fileName << std::endl;
        exit(1);
    }

    std::stringstream buffer;
    buffer << stream.rdbuf();

    return std::make_shared<std::string>(buffer.str());
}

int main(int argc, char* argv[]) {
    args::ArgumentParser p("Mapbox GL cache tool", "");
    args::HelpFlag helpFlag(p, "help", "Display this help menu", {'h'});

    args::ValueFlag<std::string> urlValue(p, "URL", "Resource URL (required)", {'u'}, args::Options::Required);
    args::ValueFlag<std::string> cacheValue(
        p, "cache", "Path to the cache database (required)", {'c'}, args::Options::Required);
    args::ValueFlag<std::string> dataValue(
        p, "data", "Path to the resource data (required)", {'d'}, args::Options::Required);
    args::ValueFlag<std::string> etagValue(p, "etag", "Cache eTag, none otherwise", {'t'});
    args::ValueFlag<unsigned long> expiresValue(p, "expires", "Expires date, will use 'now' otherwise", {'e'});
    args::ValueFlag<unsigned long> modifiedValue(p, "modified", "Modified date, will use 'now' otherwise", {'m'});

    std::unordered_map<std::string, mbgl::Resource::Kind> typeMap{{"glyphs", mbgl::Resource::Glyphs},
                                                                  {"image", mbgl::Resource::Image},
                                                                  {"source", mbgl::Resource::Source},
                                                                  {"sprite-image", mbgl::Resource::SpriteImage},
                                                                  {"sprite-json", mbgl::Resource::SpriteJSON},
                                                                  {"style", mbgl::Resource::Style},
                                                                  {"tile", mbgl::Resource::Tile}};

    std::string typeHelp("One of the following (required):");
    for (auto key : typeMap) {
        typeHelp += " " + key.first;
    }

    args::MapFlag<std::string, mbgl::Resource::Kind> typeFlag(
        p, "type", typeHelp, {"type"}, typeMap, args::Options::Required);

    args::Group tileIdGroup(p, "Coordinates (required for 'tile')", args::Group::Validators::AllOrNone);
    args::ValueFlag<int32_t> xValueFlag(tileIdGroup, "x", "Tile x coordinate", {'x'});
    args::ValueFlag<int32_t> yValueFlag(tileIdGroup, "y", "Tile y coordinate", {'y'});
    args::ValueFlag<int32_t> zValueFlag(tileIdGroup, "z", "The zoom level", {'z'});

    try {
        p.ParseCLI(argc, argv);
    } catch (const args::Help&) {
        std::cout << p;
        exit(0);
    } catch (const args::ParseError& e) {
        std::cerr << e.what() << std::endl;
        std::cerr << p;
        exit(1);
    } catch (const args::ValidationError& e) {
        std::cerr << e.what() << std::endl;
        std::cerr << p;
        exit(2);
    }

    mbgl::Response response;
    response.data = readFile(args::get(dataValue));
    response.etag = etagValue ? args::get(etagValue) : std::string();
    response.expires = expiresValue ? mbgl::Timestamp(mbgl::Seconds(args::get(expiresValue))) : mbgl::util::now();
    response.modified = modifiedValue ? mbgl::Timestamp(mbgl::Seconds(args::get(modifiedValue))) : mbgl::util::now();

    mbgl::Resource resource(args::get(typeFlag), args::get(urlValue));

    if (args::get(typeFlag) == mbgl::Resource::Tile) {
        if (!xValueFlag || !yValueFlag || !zValueFlag) {
            std::cerr << "Error: -x, -y and -z must be provided for tiles" << std::endl;
            exit(1);
        }

        resource.tileData = {{args::get(urlValue),
                              1,
                              args::get(xValueFlag),
                              args::get(yValueFlag),
                              static_cast<int8_t>(args::get(zValueFlag))}};
    }

    mbgl::util::RunLoop loop;
    mbgl::DefaultFileSource fileSource(args::get(cacheValue), ".");

    fileSource.put(resource, response);

    return 0;
}
