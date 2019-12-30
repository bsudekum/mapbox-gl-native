#include <mbgl/storage/resource_options.hpp>
#include <mbgl/util/async_request.hpp>

#include <atomic>

#include "file_source.hpp"

namespace mbgl {

std::atomic_size_t requestCount{0};
std::atomic_size_t transferredSize{0};
std::atomic_bool active{false};

ProxyFileSource::ProxyFileSource(std::shared_ptr<FileSource> defaultResourceLoader_)
    : defaultResourceLoader(std::move(defaultResourceLoader_)) {
    assert(defaultResourceLoader);
}

ProxyFileSource::~ProxyFileSource() = default;

std::unique_ptr<AsyncRequest> ProxyFileSource::request(const Resource& resource, Callback callback) {
    auto result = defaultResourceLoader->request(resource, [=](Response response) {
        std::size_t size = response.data != nullptr ? response.data->size() : 0;
        if (active) {
            requestCount++;
            transferredSize += size;
        }
        callback(response);
    });
    return result;
}

// static
void ProxyFileSource::setTrackingActive(bool active_) {
    active = active_;
    requestCount = 0;
    transferredSize = 0;
}

// static
bool ProxyFileSource::isTrackingActive() {
    return active;
}

// static
size_t ProxyFileSource::getRequestCount() {
    return requestCount;
}

// static
size_t ProxyFileSource::getTransferredSize() {
    return transferredSize;
}

} // namespace mbgl
