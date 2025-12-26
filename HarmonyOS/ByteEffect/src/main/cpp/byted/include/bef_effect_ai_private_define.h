// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.
#ifndef EFFECT_SDK_BEF_EFFECT_AI_PRIVATE_DEFINE_H
#define EFFECT_SDK_BEF_EFFECT_AI_PRIVATE_DEFINE_H

#define NAMESPACE_BEF_EFFECT_FRAMEWORK_BEGIN    namespace BEF {
#define NAMESPACE_BEF_EFFECT_FRAMEWORK_END      }

#define NAMESPACE_BEF_EFFECT_FRAMEWORK_USING    using namespace BEF; using namespace BRC;
#define CHECK_SUBFUCTION(x,y) ((x&0x0000ffff&y) == y)
#define CHECK_FUNCTION(valid) (((valid & 0xff0000) >> 16) && (valid & 0xff))

/// SUBFCTION 定义表
//--- FACE------
#define FACE_106_DETECT 0x0001
#define FACE_280_DETECT 0x0002
#define FACE_MOUTH_MASK 0x0004
#define FACE_TEETH_MASK 0x0008
#define FACE_FACE_MASK 0x0010
#define FACE_ACTION 0x0020
#define FACE_240_DETECT 0x0040
//----FACE_ATTR------
#define FACE_ATTR_EXTRA 0x0001
#define FACE_ATTR_BASE 0x0002
#define FACE_ATTR_ESPRESSION 0x0004


// --- HAND----
#define HAND_KPTS       0x0001
#define HAND_CLS        0x0002
// 为兼容TV端发出的授权
#define HAND_TV 0x0004
#define HAND_SEQ_ACTION_A_FIST 0x0008
#define HAND_SEQ_ACTION_A_PAML 0x0010
#define HAND_SKELETON_OUT 0x0020
#define HAND_SEG         0x0040
#define HAND_GROUP1 0x0080
#define HAND_GROUP2 0x0100
#define HAND_GROUP3 0x0200
#define HAND_GROUP4 0x0400
#define HAND_GROUP5 0x0800
#define HAND_SEQ_B 0x1000


// --- ANIMOJI ----
#define ANIMOJI_ALPHA 0x0001
#define ANIMOJI_BETA 0x0002
#define ANIMOJI_LANDMARK 0x0004
#define ANIMOJI_EXTRA 0x0008
#endif


