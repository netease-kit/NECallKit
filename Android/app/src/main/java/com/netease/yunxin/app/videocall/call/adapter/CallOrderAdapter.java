// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.call.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.recyclerview.widget.RecyclerView;
import com.bumptech.glide.Glide;
import com.netease.nimlib.sdk.v2.avsignalling.enums.V2NIMSignallingChannelType;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.order.CallOrder;
import com.netease.yunxin.app.videocall.utils.TimeUtils;
import com.netease.yunxin.nertc.nertcvideocall.utils.NrtcCallStatus;
import java.util.ArrayList;
import java.util.List;

/** 话单adapter */
public class CallOrderAdapter extends RecyclerView.Adapter<CallOrderAdapter.ViewHolder> {

  public static final String TIME_FORMAT = "HH:mm:ss";

  private final List<CallOrder> orders = new ArrayList<>(3);

  private final Context mContext;

  public interface OnItemClickListener {
    void onItemClick(CallOrder order);
  }

  private OnItemClickListener itemClickListener;

  //创建ViewHolder
  public static class ViewHolder extends RecyclerView.ViewHolder {
    public ImageView ivType;
    public TextView tvNickname;
    public TextView tvDuration;
    public TextView tvTime;

    public ViewHolder(View v) {
      super(v);
      ivType = v.findViewById(R.id.iv_type);
      tvNickname = v.findViewById(R.id.tv_nickname);
      tvDuration = v.findViewById(R.id.tv_duration);
      tvTime = v.findViewById(R.id.tv_time);
    }
  }

  public CallOrderAdapter(Context context) {
    this.mContext = context;
  }

  public void updateItem(List<CallOrder> orders) {
    this.orders.clear();
    this.orders.addAll(orders);
    notifyDataSetChanged();
  }

  public void setOnItemClickListener(OnItemClickListener listener) {
    this.itemClickListener = listener;
  }

  @Override
  public void onBindViewHolder(ViewHolder holder, int position) {
    CallOrder order = orders.get(position);
    if (order != null) {
      holder.tvNickname.setText(order.getSessionId());
      if (order.getStatus() == NrtcCallStatus.NrtcCallStatusComplete) {

        int durationSeconds = Integer.MAX_VALUE;
        for (CallOrder.CallDuration duration : order.getDurationList()) {
          durationSeconds = Math.min(durationSeconds, duration.getDuration());
        }
        String textString = TimeUtils.secToTime(durationSeconds);
        holder.tvDuration.setText("\t" + textString);
        holder.tvTime.setText(
            TimeUtils.millis2String(
                order.getReceivedTime() - durationSeconds * 1000L, TIME_FORMAT));
        holder.tvNickname.setTextColor(mContext.getResources().getColor(R.color.white));
        holder.tvTime.setTextColor(mContext.getResources().getColor(R.color.white));
        holder.tvDuration.setTextColor(mContext.getResources().getColor(R.color.white));
        if (!order.isSelf()) {
          if (order.getType()
              == V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_AUDIO.getValue()) {
            Glide.with(mContext).load(R.drawable.audio_in_normal).into(holder.ivType);
          } else if (order.getType()
              == V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_VIDEO.getValue()) {
            Glide.with(mContext).load(R.drawable.video_in_normal).into(holder.ivType);
          }
        } else {
          if (order.getType()
              == V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_AUDIO.getValue()) {
            Glide.with(mContext).load(R.drawable.audio_out_normal).into(holder.ivType);
          } else if (order.getType()
              == V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_VIDEO.getValue()) {
            Glide.with(mContext).load(R.drawable.video_out_normal).into(holder.ivType);
          }
        }
      } else {
        holder.tvTime.setText(TimeUtils.millis2String(order.getReceivedTime(), TIME_FORMAT));
        holder.tvNickname.setTextColor(mContext.getResources().getColor(R.color.red));
        holder.tvTime.setTextColor(mContext.getResources().getColor(R.color.red));
        holder.tvDuration.setText("");
        if (order.isSelf()) {
          if (order.getType()
              == V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_AUDIO.getValue()) {
            Glide.with(mContext).load(R.drawable.audio_in_failed).into(holder.ivType);
          } else if (order.getType()
              == V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_VIDEO.getValue()) {
            Glide.with(mContext).load(R.drawable.video_in_failed).into(holder.ivType);
          }
        } else {
          if (order.getType()
              == V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_AUDIO.getValue()) {
            Glide.with(mContext).load(R.drawable.audio_out_failed).into(holder.ivType);
          } else if (order.getType()
              == V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_VIDEO.getValue()) {
            Glide.with(mContext).load(R.drawable.video_out_failed).into(holder.ivType);
          }
        }
      }

      holder.itemView.setOnClickListener(
          view -> {
            if (itemClickListener != null) {
              itemClickListener.onItemClick(order);
            }
          });
    }
  }

  @Override
  public int getItemCount() {
    return orders.size();
  }

  @Override
  public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
    View v =
        LayoutInflater.from(parent.getContext())
            .inflate(R.layout.call_order_item_layout, parent, false);
    return new ViewHolder(v);
  }
}
