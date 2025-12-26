#ifndef BEF_AI_IMAGE_QUALITY_ENHANCEMENT_PRIVATE_DEFINE_H
#define BEF_AI_IMAGE_QUALITY_ENHANCEMENT_PRIVATE_DEFINE_H

#include "LensConfigType.h"
#include "LensEngine.h"
#include "ai_tob/HandlesManager.hpp"
#include "bef_ai_image_quality_enhancement_public_define.h"
#include <vector>

using namespace LENS::FRAMEWORK;
USING_NAME_SPACE_LabcvTob_HandleManager

// lens的算法中，我们需要保持1v1的Handle, 1 flowgraph handle with 1 engine interface
typedef struct engine_and_graph_handles
{
    ILensFlowGraphInterface* graph;
    ILensEngineInterface* engine;
    IOneKeyGraphInterface* oneKeygraph;
}engine_and_graph_handles;

template<typename T>
int getRealHandle(bef_image_quality_enhancement_handle handle, const char* handleType, T** retHandle){
    BEF_GET_HANDLE_RET_WHEN_FAILED(handleType, handle, *retHandle, T*);
    return 0;
}

template<typename T>
int removeHandle(bef_image_quality_enhancement_handle handle, const char* handleType, T** retHandle){
    BEF_GET_HANDLE_RET_WHEN_FAILED(handleType, handle, *retHandle, T*);
    BEF_REMOVE_HANDLE(handleType, handle);
    return 0;
}

#endif
