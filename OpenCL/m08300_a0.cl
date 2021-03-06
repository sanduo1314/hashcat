/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

//#define NEW_SIMD_CODE

#include "inc_vendor.cl"
#include "inc_hash_constants.h"
#include "inc_hash_functions.cl"
#include "inc_types.cl"
#include "inc_common.cl"
#include "inc_rp_optimized.h"
#include "inc_rp_optimized.cl"
#include "inc_scalar.cl"
#include "inc_hash_sha1.cl"

__kernel void m08300_mxx (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u32 gid_max)
{
  /**
   * modifier
   */

  const u32 lid = get_local_id (0);
  const u32 gid = get_global_id (0);

  if (gid >= gid_max) return;

  /**
   * base
   */

  const u32 pw_len = pws[gid].pw_len;

  const u32 pw_lenv = ceil ((float) pw_len / 4);

  u32 w[64] = { 0 };

  for (int idx = 0; idx < pw_lenv; idx++)
  {
    w[idx] = pws[gid].i[idx];
  }

  const u32 salt_len = salt_bufs[salt_pos].salt_len;

  const u32 salt_lenv = ceil ((float) salt_len / 4);

  u32 s[64] = { 0 };

  for (int idx = 0; idx < salt_lenv; idx++)
  {
    s[idx] = swap32_S (salt_bufs[salt_pos].salt_buf[idx]);
  }

  const u32 salt_len_pc = salt_bufs[salt_pos].salt_len_pc;

  const u32 salt_len_pcv = ceil ((float) salt_len_pc / 4);

  u32 s_pc[64] = { 0 };

  for (int idx = 0; idx < salt_len_pcv; idx++)
  {
    s_pc[idx] = swap32_S (salt_bufs[salt_pos].salt_buf_pc[idx]);
  }

  const u32 salt_iter = salt_bufs[salt_pos].salt_iter;

  /**
   * loop
   */

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos++)
  {
    // todo: add rules engine

    sha1_ctx_t ctx1;

    sha1_init (&ctx1);

    ctx1.w0[0] = (pw_len & 0xff) << 24;

    ctx1.len = 1;

    sha1_update_swap (&ctx1, w, pw_len);

    sha1_update (&ctx1, s_pc, salt_len_pc + 1);

    sha1_update (&ctx1, s, salt_len);

    sha1_final (&ctx1);

    u32 digest[5];

    digest[0] = ctx1.h[0];
    digest[1] = ctx1.h[1];
    digest[2] = ctx1.h[2];
    digest[3] = ctx1.h[3];
    digest[4] = ctx1.h[4];

    // iterations

    for (u32 i = 0; i < salt_iter; i++)
    {
      sha1_ctx_t ctx;

      sha1_init (&ctx);

      ctx.w0[0] = digest[0];
      ctx.w0[1] = digest[1];
      ctx.w0[2] = digest[2];
      ctx.w0[3] = digest[3];
      ctx.w1[0] = digest[4];

      ctx.len = 20;

      sha1_update (&ctx, s, salt_len);

      sha1_final (&ctx);

      digest[0] = ctx.h[0];
      digest[1] = ctx.h[1];
      digest[2] = ctx.h[2];
      digest[3] = ctx.h[3];
      digest[4] = ctx.h[4];
    }

    const u32 r0 = digest[DGST_R0];
    const u32 r1 = digest[DGST_R1];
    const u32 r2 = digest[DGST_R2];
    const u32 r3 = digest[DGST_R3];

    COMPARE_M_SCALAR (r0, r1, r2, r3);
  }
}

__kernel void m08300_sxx (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u32 gid_max)
{
  /**
   * modifier
   */

  const u32 lid = get_local_id (0);
  const u32 gid = get_global_id (0);

  if (gid >= gid_max) return;

  /**
   * digest
   */

  const u32 search[4] =
  {
    digests_buf[digests_offset].digest_buf[DGST_R0],
    digests_buf[digests_offset].digest_buf[DGST_R1],
    digests_buf[digests_offset].digest_buf[DGST_R2],
    digests_buf[digests_offset].digest_buf[DGST_R3]
  };

  /**
   * base
   */

  const u32 pw_len = pws[gid].pw_len;

  const u32 pw_lenv = ceil ((float) pw_len / 4);

  u32 w[64] = { 0 };

  for (int idx = 0; idx < pw_lenv; idx++)
  {
    w[idx] = pws[gid].i[idx];
  }

  const u32 salt_len = salt_bufs[salt_pos].salt_len;

  const u32 salt_lenv = ceil ((float) salt_len / 4);

  u32 s[64] = { 0 };

  for (int idx = 0; idx < salt_lenv; idx++)
  {
    s[idx] = swap32_S (salt_bufs[salt_pos].salt_buf[idx]);
  }

  const u32 salt_len_pc = salt_bufs[salt_pos].salt_len_pc;

  const u32 salt_len_pcv = ceil ((float) salt_len_pc / 4);

  u32 s_pc[64] = { 0 };

  for (int idx = 0; idx < salt_len_pcv; idx++)
  {
    s_pc[idx] = swap32_S (salt_bufs[salt_pos].salt_buf_pc[idx]);
  }

  const u32 salt_iter = salt_bufs[salt_pos].salt_iter;

  /**
   * loop
   */

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos++)
  {
    // todo: add rules engine

    sha1_ctx_t ctx1;

    sha1_init (&ctx1);

    ctx1.w0[0] = (pw_len & 0xff) << 24;

    ctx1.len = 1;

    sha1_update_swap (&ctx1, w, pw_len);

    sha1_update (&ctx1, s_pc, salt_len_pc + 1);

    sha1_update (&ctx1, s, salt_len);

    sha1_final (&ctx1);

    u32 digest[5];

    digest[0] = ctx1.h[0];
    digest[1] = ctx1.h[1];
    digest[2] = ctx1.h[2];
    digest[3] = ctx1.h[3];
    digest[4] = ctx1.h[4];

    // iterations

    for (u32 i = 0; i < salt_iter; i++)
    {
      sha1_ctx_t ctx;

      sha1_init (&ctx);

      ctx.w0[0] = digest[0];
      ctx.w0[1] = digest[1];
      ctx.w0[2] = digest[2];
      ctx.w0[3] = digest[3];
      ctx.w1[0] = digest[4];

      ctx.len = 20;

      sha1_update (&ctx, s, salt_len);

      sha1_final (&ctx);

      digest[0] = ctx.h[0];
      digest[1] = ctx.h[1];
      digest[2] = ctx.h[2];
      digest[3] = ctx.h[3];
      digest[4] = ctx.h[4];
    }

    const u32 r0 = digest[DGST_R0];
    const u32 r1 = digest[DGST_R1];
    const u32 r2 = digest[DGST_R2];
    const u32 r3 = digest[DGST_R3];

    COMPARE_S_SCALAR (r0, r1, r2, r3);
  }
}
