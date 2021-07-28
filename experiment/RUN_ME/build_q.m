% Creates a queue of stimuli for run_q.
% Stimuli is placed in 'q' according to its display time (each slot in 'q' lasts 1/disp_rate).
% name - type of queue: 'categor', 'categor_wo_prime', 'recog'.
function q = build_q(trials, name)
    switch name
        case 'categor'
            q = struct('txtr',NaN(p.CATEGOR_CAP_LENGTH),...
                'txt'NaN(p.CATEGOR_CAP_LENGTH),...
                'name'NaN(p.CATEGOR_CAP_LENGTH));
            q.txtr(p.MASK1_TIME) = p.MASK1_TXTR;
            q.txtr(p.MASK2_TIME) = p.MASK2_TXTR;
            q.txtr(p.MASK3_TIME) = p.MASK3_TXTR;
            q.txtr(p.FIX_TIME) = p.FIXATION_TXTR;
            q.txtr(p.PRIME_TIME) = p.CATEGOR_TXTR;
            q.txtr(p.TARGET_TIME) = p.CATEGOR_TXTR;
            q.txtr(p.LATE_RES_TIME) = p.LATE_RES_TXTR;
            q.txtr(p.CATEGOR_TIME) = p.CATEGOR_TXTR;
            q.txt(p.PRIME_TIME) = double(trials.prime(1));
            q.txt(p.TARGET_TIME) = double(trials.target(1));
            q.name(p.MASK1_TIME) = 'mask1';
            q.name(p.MASK2_TIME) = 'mask2';
            q.name(p.MASK3_TIME) = 'mask3';
            q.name(p.FIX_TIME) = 'fix';
            q.name(p.PRIME_TIME) = 'prime';
            q.name(p.TARGET_TIME) = 'target';
            q.name(p.LATE_RES_TIME) = p.LATE_RES_TXTR;
            q.name(p.CATEGOR_TIME) = p.CATEGOR_TXTR;
        case 'categor_wo_prime'
            q = struct('txtr',NaN(p.CATEGOR_CAP_LENGTH),...
                'txt'NaN(p.CATEGOR_CAP_LENGTH),...
                'name'NaN(p.CATEGOR_CAP_LENGTH));
            q.txtr(p.MASK1_TIME) = p.MASK1_TXTR;
            q.txtr(p.MASK2_TIME) = p.MASK2_TXTR;
            q.txtr(p.MASK3_TIME) = p.MASK3_TXTR;
            q.txtr(p.FIX_TIME) = p.FIXATION_TXTR;
            q.txtr(p.TARGET_TIME) = p.CATEGOR_TXTR;
            q.txtr(p.LATE_RES_TIME) = p.LATE_RES_TXTR;
            q.txtr(p.CATEGOR_TIME) = p.CATEGOR_TXTR;
            q.txt(p.TARGET_TIME) = double(trials.target(1));
            q.name(p.MASK1_TIME) = 'mask1';
            q.name(p.MASK2_TIME) = 'mask2';
            q.name(p.MASK3_TIME) = 'mask3';
            q.name(p.FIX_TIME) = 'fix';
            q.name(p.TARGET_TIME) = 'target';
            q.name(p.LATE_RES_TIME) = p.LATE_RES_TXTR;
            q.name(p.CATEGOR_TIME) = p.CATEGOR_TXTR;
        case 'recog'
            q = struct('txtr',NaN(p.RECOG_CAP_LENGTH),...
                'txt'NaN(p.RECOG_CAP_LENGTH),...
                'name'NaN(p.RECOG_CAP_LENGTH));
            q.txtr(1) = p.RECOG_TXTR;
            q.name(1) = 'recog';
    end
end