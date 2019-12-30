#pragma once

#include <mbgl/storage/file_source.hpp>

namespace mbgl {

class ProxyFileSource : public FileSource {
public:
    ProxyFileSource(std::shared_ptr<FileSource>);
    ~ProxyFileSource();

    std::unique_ptr<AsyncRequest> request(const Resource&, Callback) override;
    bool canRequest(const Resource&) const override { return true; }

    /**
     * @brief Starts/stops metrics tracking.
     */
    static void setTrackingActive(bool);
    /**
     * @brief Returns metrics tracking status.
     */
    static bool isTrackingActive();
    /**
     * @brief Returns the total amount of requests.
     *
     * @return size_t
     */
    static size_t getRequestCount();

    /**
     * @brief Returns the size of transferred data (in bytes).
     *
     * @return size_t
     */
    static size_t getTransferredSize();

private:
    std::shared_ptr<FileSource> defaultResourceLoader;
};

} // namespace mbgl
