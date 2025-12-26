//
//  bef_effect_ai_network_proxy.hpp
//  effect-sdk
//

#ifndef bef_effect_ai_network_proxy_hpp
#define bef_effect_ai_network_proxy_hpp

#include <string>
#include <vector>
#include <unordered_map>
#include <functional>
#include <memory>

namespace bef {
namespace network {
namespace proxy {
using HeaderMap = std::unordered_map<std::string, std::string>;

enum class Method {
    Get,
    Post
};

struct Request {
    Method method;
    bool sync;
    std::string url;
    HeaderMap headers;
    std::vector<uint8_t> body;
    int32_t requestId;
};

struct Response {
    bool success;
    int32_t statusCode;
    std::string errorMsg;
    HeaderMap header;
    std::shared_ptr<Request> request;
    std::vector<uint8_t> data;
    
    Response(std::shared_ptr<Request> req) : request{req} {};
    Response(std::shared_ptr<Request> req, const std::string& str)
        : request{req}, data{str.begin(), str.end()} {};
};


void onRequest(std::function<void(std::shared_ptr<Request>)>&& oncall);

void onResponse(std::shared_ptr<Response> response);

}}}

#endif /* bef_effect_ai_network_proxy_hpp */
