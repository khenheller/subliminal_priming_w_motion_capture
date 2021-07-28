% Creates a queue of stimuli for run_q.
% Stimuli is placed in 'q' according to its display time (each slot in 'q' lasts 1/disp_rate).
% name - type of queue: 'categor', 'categor_wo_prime', 'recog'.
function q = build_q(trials, name, p)
    word_size = size(trials.prime{1},2);
    q = struct('txtr',NaN(p.MAX_CAP_LENGTH,1),...
                'txt1',NaN(p.MAX_CAP_LENGTH,word_size),...
                'txt2',NaN(p.MAX_CAP_LENGTH,word_size),...
                'name',string(NaN(p.MAX_CAP_LENGTH,1)));
    switch name
        case 'categor'
            q.txtr(p.MASK1_TIME) = p.MASK1_TXTR;
            q.txtr(p.MASK2_TIME) = p.MASK2_TXTR;
            q.txtr(p.MASK3_TIME) = p.MASK3_TXTR;
            q.txtr(p.FIX_TIME) = p.FIXATION_TXTR;
            q.txtr(p.PRIME_TIME) = p.CATEGOR_TXTR;
            q.txtr(p.TARGET_TIME) = p.CATEGOR_TXTR;
            q.txtr(p.LATE_RES_TIME) = p.LATE_RES_TXTR;
            q.txtr(p.CATEGOR_TIME) = p.CATEGOR_TXTR;
            q.txt1(p.PRIME_TIME,:) = double(trials.prime{1});
            q.txt1(p.TARGET_TIME,:) = double(trials.target{1});
            q.name(p.MASK1_TIME) = 'mask1';
            q.name(p.MASK2_TIME) = 'mask2';
            q.name(p.MASK3_TIME) = 'mask3';
            q.name(p.FIX_TIME) = 'fix';
            q.name(p.PRIME_TIME) = 'prime';
            q.name(p.TARGET_TIME) = 'target';
            q.name(p.LATE_RES_TIME) = 'late_res';
            q.name(p.CATEGOR_TIME) = 'categor';
        case 'categor_wo_prime'
            q.txtr(p.MASK1_TIME) = p.MASK1_TXTR;
            q.txtr(p.MASK2_TIME) = p.MASK2_TXTR;
            q.txtr(p.MASK3_TIME) = p.MASK3_TXTR;
            q.txtr(p.FIX_TIME) = p.FIXATION_TXTR;
            q.txtr(p.TARGET_TIME) = p.CATEGOR_TXTR;
            q.txtr(p.LATE_RES_TIME) = p.LATE_RES_TXTR;
            q.txtr(p.CATEGOR_TIME) = p.CATEGOR_TXTR;
            q.txt1(p.TARGET_TIME,:) = double(trials.target{1});
            q.name(p.MASK1_TIME) = 'mask1';
            q.name(p.MASK2_TIME) = 'mask2';
            q.name(p.MASK3_TIME) = 'mask3';
            q.name(p.FIX_TIME) = 'fix';
            q.name(p.TARGET_TIME) = 'target';
            q.name(p.LATE_RES_TIME) = 'late_res';
            q.name(p.CATEGOR_TIME) = 'categor';
        case 'recog'
            q.txtr(1) = p.RECOG_TXTR;
            q.txtr(end) = p.LATE_RES_TXTR;
            q.name(1) = 'recog';
            q.name(end) = 'late_res';
             if trials.prime_left(1)
                q.txt1(1,:) = trials.prime{1};
                q.txt2(1,:) = trials.distractor{1};
            else
                q.txt1(1,:) = trials.distractor{1};
                q.txt2(1,:) = trials.prime{1};
            end
    end
    q.len = size(q.txt1,1);
end